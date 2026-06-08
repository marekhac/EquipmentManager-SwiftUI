const WebSocket = require('ws');

const wss = new WebSocket.Server({ port: 8080 });

const statuses = ['STOPPED', 'STARTUP', 'PRODUCING'];

wss.on('connection', (ws) => {
    console.log('Client connected');

    ws.on('close', () => {
        console.log('Client disconnected');
    });
});

// Single interval for everyone
setInterval(() => {
    const randomStatus =
        statuses[Math.floor(Math.random() * statuses.length)];

    const message = JSON.stringify({
        type: 'update',
        equipmentId: '550e8400-e29b-41d4-a716-446655440000',
        status: randomStatus
    });

    console.log(message);

    // Broadcast to all connected clients
    wss.clients.forEach((client) => {
        if (client.readyState === WebSocket.OPEN) {
            client.send(message);
        }
    });

}, 3000);