import com.sun.net.httpserver.HttpServer;
import java.io.IOException;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;

public class Main {
        public static void main(String[] args) throws IOException {
                int port = Integer.parseInt(System.getenv().getOrDefault("PORT", "8080"));
                HttpServer server = HttpServer.create(new InetSocketAddress("0.0.0.0", port), 0);

                server.createContext("/", exchange -> {
                        String html = """
                                        <!doctype html>
                                        <html lang="en">
                                        <head>
                                            <meta charset="utf-8">
                                            <meta name="viewport" content="width=device-width, initial-scale=1">
                                            <title>Java Shop</title>
                                            <style>
                                                * { box-sizing: border-box; }
                                                body { margin: 0; min-height: 100vh; display: grid; place-items: center;
                                                    font-family: system-ui, sans-serif; color: #172033;
                                                    background: linear-gradient(135deg, #eef2ff, #f8fafc); }
                                                main { width: min(640px, 90vw); padding: 56px; border-radius: 24px;
                                                    background: white; box-shadow: 0 24px 70px #27346920; }
                                                .tag { color: #5546d7; font-weight: 700; letter-spacing: .12em;
                                                    text-transform: uppercase; font-size: .8rem; }
                                                h1 { margin: 16px 0; font-size: clamp(2.4rem, 7vw, 4rem);
                                                    line-height: 1.05; letter-spacing: -.05em; }
                                                p { color: #647084; font-size: 1.1rem; line-height: 1.7; }
                                                a { display: inline-block; margin-top: 16px; padding: 13px 20px;
                                                    border-radius: 12px; background: #5546d7; color: white;
                                                    text-decoration: none; font-weight: 700; }
                                            </style>
                                        </head>
                                        <body><main>
                                            <div class="tag">Java • Docker • localhost</div>
                                            <h1>Your shop is online.</h1>
                                            <p>This sample website is served by a lightweight Java HTTP server
                                            running inside a Docker container.</p>
                                            <a href="#products">Explore the demo</a>
                                        </main></body>
                                        </html>
                                        """;
                        byte[] response = html.getBytes(StandardCharsets.UTF_8);
                        exchange.getResponseHeaders().set("Content-Type", "text/html; charset=UTF-8");
                        exchange.sendResponseHeaders(200, response.length);
                        try (var output = exchange.getResponseBody()) {
                                output.write(response);
                        }
                });

                server.start();
                System.out.println("Website is running on port " + port);
        }
}
