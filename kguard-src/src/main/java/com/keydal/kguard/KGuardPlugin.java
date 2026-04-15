package com.keydal.kguard;

import com.google.inject.Inject;
import com.velocitypowered.api.event.Subscribe;
import com.velocitypowered.api.event.proxy.ProxyInitializeEvent;
import com.velocitypowered.api.event.proxy.ProxyShutdownEvent;
import com.velocitypowered.api.plugin.Plugin;
import com.velocitypowered.api.plugin.annotation.DataDirectory;
import com.velocitypowered.api.proxy.ProxyServer;
import net.kyori.adventure.text.Component;
import net.kyori.adventure.text.format.NamedTextColor;
import org.slf4j.Logger;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.concurrent.TimeUnit;

@Plugin(
        id = "kguard",
        name = "kGuard",
        version = "1.0.0",
        description = "kVelocity license guard — KEYDAL Projects",
        authors = {"Egemen KEYDAL"}
)
public class KGuardPlugin {

    private static final String PRODUCT_CODE = "KVELO";

    private final ProxyServer server;
    private final Logger logger;
    private final Path dataDirectory;
    private LicenseClient license;

    @Inject
    public KGuardPlugin(ProxyServer server, Logger logger, @DataDirectory Path dataDirectory) {
        this.server = server;
        this.logger = logger;
        this.dataDirectory = dataDirectory;
    }

    @Subscribe
    public void onProxyInit(ProxyInitializeEvent event) {
        logger.info("#############################################");
        logger.info("#  kGuard v1.0.0  |  KEYDAL Projects        #");
        logger.info("#  Developer: Egemen KEYDAL                 #");
        logger.info("#############################################");

        String licenseKey = loadLicenseKey();
        if (licenseKey == null || licenseKey.isEmpty() || licenseKey.equals("YOUR-LICENSE-KEY-HERE")) {
            logger.error("");
            logger.error("=========================================================");
            logger.error("  kVelocity lisans anahtari bulunamadi!");
            logger.error("  plugins/kguard/config.yml icine license-key ekleyin.");
            logger.error("  Lisans almak icin: https://keydal.net");
            logger.error("=========================================================");
            logger.error("");
            scheduleShutdown("Lisans anahtari eksik");
            return;
        }

        license = new LicenseClient(logger, PRODUCT_CODE, licenseKey);

        if (!license.verify()) {
            logger.error("");
            logger.error("=========================================================");
            logger.error("  kVelocity lisans dogrulamasi BASARISIZ!");
            logger.error("  Proxy 10 saniye icinde kapatilacak.");
            logger.error("  Sebep: " + license.getLastError());
            logger.error("  Destek: https://keydal.net");
            logger.error("=========================================================");
            logger.error("");
            scheduleShutdown("Lisans gecersiz: " + license.getLastError());
            return;
        }

        logger.info("Lisans dogrulandi, kVelocity calismaya basladi.");
        license.startHeartbeat(server, this);
    }

    @Subscribe
    public void onProxyShutdown(ProxyShutdownEvent event) {
        if (license != null) {
            license.shutdown();
        }
    }

    public void onHeartbeatFailed(String reason) {
        logger.error("Heartbeat reddedildi: " + reason + " — proxy kapatiliyor.");
        scheduleShutdown("Heartbeat: " + reason);
    }

    private void scheduleShutdown(String reason) {
        server.getScheduler().buildTask(this, () -> {
            Component kickMsg = Component.text("kVelocity lisans hatasi: " + reason, NamedTextColor.RED);
            server.getAllPlayers().forEach(p -> p.disconnect(kickMsg));
            server.shutdown(Component.text("kVelocity lisans hatasi", NamedTextColor.RED));
        }).delay(10L, TimeUnit.SECONDS).schedule();
    }

    private String loadLicenseKey() {
        try {
            if (!Files.exists(dataDirectory)) {
                Files.createDirectories(dataDirectory);
            }
            Path configPath = dataDirectory.resolve("config.yml");
            if (!Files.exists(configPath)) {
                String template = "# kGuard Configuration - KEYDAL Projects\n" +
                        "# Lisans anahtarinizi asagiya girin.\n" +
                        "# Lisans almak icin: https://keydal.net\n" +
                        "\n" +
                        "license-key: \"YOUR-LICENSE-KEY-HERE\"\n";
                Files.writeString(configPath, template, StandardCharsets.UTF_8);
                logger.warn("plugins/kguard/config.yml olusturuldu. Lisans anahtarinizi ekleyin.");
                return null;
            }
            for (String line : Files.readAllLines(configPath, StandardCharsets.UTF_8)) {
                String trimmed = line.trim();
                if (trimmed.startsWith("license-key:")) {
                    String value = trimmed.substring("license-key:".length()).trim();
                    if (value.startsWith("\"") && value.endsWith("\"") && value.length() >= 2) {
                        value = value.substring(1, value.length() - 1);
                    } else if (value.startsWith("'") && value.endsWith("'") && value.length() >= 2) {
                        value = value.substring(1, value.length() - 1);
                    }
                    return value;
                }
            }
        } catch (IOException e) {
            logger.error("Config okuma hatasi: " + e.getMessage());
        }
        return null;
    }
}
