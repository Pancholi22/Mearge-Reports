class ScannerControl {
    constructor(containerId) {
        this.containerId = containerId;
        this.initialize();
    }

    initialize() {
        document.addEventListener("LoadScannerUI", () => this.loadScannerUI());
    }

    loadScannerUI() {
        let container = document.getElementById(this.containerId);
        if (container) {
            let iframeSrc = `${window.location.origin}/I_Scan-Documents/resources/Hello-World.html`;

            container.innerHTML = `<iframe src="${iframeSrc}" width="100%" height="500px" frameborder="0"></iframe>`;
            console.log("Scanner UI Loaded.");
        } else {
            console.error("Container not found: " + this.containerId);
        }
    }
}

// Make ScannerControl globally available
window.ScannerControl = ScannerControl;
