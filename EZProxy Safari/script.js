// Listen for messages from the Safari extension
safari.self.addEventListener("message", function(event) {
    if (event.name === "redirectToProxy") {
        // Use location.assign() to preserve history
        // This allows the user to use the back button
        window.location.assign(event.message.proxyURL);
    }
});
