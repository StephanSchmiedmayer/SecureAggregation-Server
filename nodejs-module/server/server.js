const httpServer = require("http").createServer();
const utils = require("../utils");

/**
 * Secure Aggregation Server
 */
class SAServer {
    /**
     * @param settings Settings about the server
     * @param settings.host Host url
     * @param settings.port Port on which to connect
     * @param settings.n Number of users
     * @param settings.k Number of client responses required before aggregation process begins
     */
    constructor(settings = {}) {
        const defaults = {
            host: 'localhost',
            port: 8080
        };
        this.settings = utils.setDefaults(settings, defaults);
    }

    start() {
        console.log("Starting the Server..");

        const io = require("socket.io")(httpServer, {
            cors: {
                origin: `http://${this.settings.host}:${this.settings.port}`,
            },
        });

        io.on("connection", (socket) => {
            console.log(`We have a connection ! ${socket.id}`);
        });

        httpServer.listen(this.settings.port);
    }
}

exports = module.exports = SAServer;
