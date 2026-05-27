const WebSocket = require('ws');

const wss = new WebSocket.Server({ port: 8080 });

wss.on('connection', (ws) => {
    console.log('Client connected');

    // Every 5 seconds, we send random status to one of the machines
    setInterval(() => {
        const statuses = ['STOPPED', 'STARTUP', 'PRODUCING'];
        const randomStatus = statuses[Math.floor(Math.random() * statuses.length)];
        
        const message = {
            type: 'update',
            equipmentId: '550e8400-e29b-41d4-a716-446655440000',
            status: randomStatus
        };
        
		console.log(JSON.stringify(message));
		
        ws.send(JSON.stringify(message));
    }, 3000);

    ws.on('close', () => {
        console.log('Client disconnected');
    });
});
