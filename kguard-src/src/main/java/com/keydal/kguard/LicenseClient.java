package com.keydal.kguard;

import com.velocitypowered.api.proxy.ProxyServer;
import com.velocitypowered.api.scheduler.ScheduledTask;
import org.slf4j.Logger;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.io.DataOutputStream;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.Enumeration;
import java.util.concurrent.TimeUnit;

public class LicenseClient {

    private static final String API_BASE = "https://klicense-a4fns.bunny.run";
    private static final String SECRET_HEX = "8e7c5da759b9fa2f0ef38e9ef75488ed91a8b302b7d3652c38aa9cc2a11a4ec0";
    private static final long HEARTBEAT_INTERVAL_MINUTES = 5L;

    private final Logger logger;
    private final String productCode;
    private final String licenseKey;
    private final String serverId;
    private ScheduledTask heartbeatTask;
    private volatile String lastError = "";

    public LicenseClient(Logger logger, String productCode, String licenseKey) {
        this.logger = logger;
        this.productCode = productCode;
        this.licenseKey = licenseKey;
        this.serverId = computeServerId();
    }

    public String getLastError() {
        return lastError;
    }

    public boolean verify() {
        try {
            String body = String.format(
                    "{\"license_key\":\"%s\",\"product_code\":\"%s\",\"server_id\":\"%s\",\"server_name\":\"kVelocity\"}",
                    escape(licenseKey), escape(productCode), escape(serverId));

            HttpResponse r = post("/verify", body);
            if (r.code == 200) {
                logger.info("License verified: " + productCode + " (server_id=" + serverId.substring(0, 8) + "...)");
                return true;
            }
            lastError = parseCode(r.body) + " (HTTP " + r.code + ")";
            logger.error("Verify failed: " + lastError);
            return false;
        } catch (Exception e) {
            lastError = "API erisim hatasi: " + e.getMessage();
            logger.error("Verify exception: " + e.getMessage());
            return false;
        }
    }

    public void startHeartbeat(ProxyServer server, KGuardPlugin plugin) {
        heartbeatTask = server.getScheduler().buildTask(plugin, () -> {
            try {
                String body = String.format(
                        "{\"license_key\":\"%s\",\"server_id\":\"%s\"}",
                        escape(licenseKey), escape(serverId));
                HttpResponse r = post("/heartbeat", body);
                if (r.code == 409) {
                    String reason = parseCode(r.body);
                    plugin.onHeartbeatFailed(reason);
                } else if (r.code >= 400) {
                    logger.warn("Heartbeat anomali: HTTP " + r.code + " - " + r.body);
                }
            } catch (Exception e) {
                logger.warn("Heartbeat exception: " + e.getMessage());
            }
        }).repeat(HEARTBEAT_INTERVAL_MINUTES, TimeUnit.MINUTES)
          .delay(HEARTBEAT_INTERVAL_MINUTES, TimeUnit.MINUTES)
          .schedule();
    }

    public void shutdown() {
        if (heartbeatTask != null) {
            heartbeatTask.cancel();
        }
    }

    private HttpResponse post(String path, String body) throws Exception {
        long ts = System.currentTimeMillis() / 1000L;
        String sig = hmacSha256(SECRET_HEX, ts + "." + body);

        HttpURLConnection c = (HttpURLConnection) URI.create(API_BASE + path).toURL().openConnection();
        c.setRequestMethod("POST");
        c.setConnectTimeout(5000);
        c.setReadTimeout(10000);
        c.setDoOutput(true);
        c.setRequestProperty("Content-Type", "application/json");
        c.setRequestProperty("User-Agent", "kGuard/1.0 (kVelocity)");
        c.setRequestProperty("X-KEYDAL-Timestamp", String.valueOf(ts));
        c.setRequestProperty("X-KEYDAL-Signature", sig);

        try (DataOutputStream out = new DataOutputStream(c.getOutputStream())) {
            out.write(body.getBytes(StandardCharsets.UTF_8));
        }

        int code = c.getResponseCode();
        InputStream is = (code >= 200 && code < 300) ? c.getInputStream() : c.getErrorStream();
        String respBody = (is == null) ? "" : new String(is.readAllBytes(), StandardCharsets.UTF_8);
        return new HttpResponse(code, respBody);
    }

    private static String hmacSha256(String keyHex, String message) throws Exception {
        Mac mac = Mac.getInstance("HmacSHA256");
        mac.init(new SecretKeySpec(keyHex.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
        byte[] h = mac.doFinal(message.getBytes(StandardCharsets.UTF_8));
        StringBuilder sb = new StringBuilder(h.length * 2);
        for (byte b : h) sb.append(String.format("%02x", b));
        return sb.toString();
    }

    private static String computeServerId() {
        try {
            StringBuilder src = new StringBuilder();
            Enumeration<NetworkInterface> nis = NetworkInterface.getNetworkInterfaces();
            while (nis.hasMoreElements()) {
                NetworkInterface ni = nis.nextElement();
                if (ni.isLoopback() || ni.isVirtual()) continue;
                byte[] mac = ni.getHardwareAddress();
                if (mac != null) {
                    for (byte b : mac) src.append(String.format("%02x", b));
                }
            }
            src.append(System.getProperty("os.name", ""));
            src.append(System.getProperty("os.arch", ""));
            src.append(InetAddress.getLocalHost().getHostName());

            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] h = md.digest(src.toString().getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : h) sb.append(String.format("%02x", b));
            return sb.substring(0, 32);
        } catch (Exception e) {
            return "fallback-" + Math.abs(("" + System.nanoTime()).hashCode());
        }
    }

    private static String escape(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }

    private static String parseCode(String json) {
        if (json == null) return "unknown";
        int i = json.indexOf("\"code\"");
        if (i < 0) return "unknown";
        int q1 = json.indexOf('"', json.indexOf(':', i) + 1);
        if (q1 < 0) return "unknown";
        int q2 = json.indexOf('"', q1 + 1);
        if (q2 < 0) return "unknown";
        return json.substring(q1 + 1, q2);
    }

    private static class HttpResponse {
        final int code;
        final String body;
        HttpResponse(int code, String body) { this.code = code; this.body = body; }
    }
}
