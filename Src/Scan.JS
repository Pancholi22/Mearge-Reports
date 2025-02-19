class ScannerControl {
    constructor(containerId) {
        this.containerId = containerId;
        this.DWTObject = null;
        this.initialize();
    }

    initialize() {
        Dynamsoft.DWT.RegisterEvent("OnWebTwainReady", () => {
            this.DWTObject = Dynamsoft.DWT.GetWebTwain(this.containerId);
        });

        document.addEventListener("acquireImage", () => this.acquireImage());
        document.addEventListener("downloadPDF", () => this.downloadPDF());
    }

    acquireImage() {
        if (this.DWTObject) {
            this.DWTObject.SelectSourceAsync().then(() => {
                return this.DWTObject.AcquireImageAsync({
                    IfCloseSourceAfterAcquire: true 
                });
            }).catch(exp => {
                console.error("Scan Error:", exp.message);
            });
        }
    }

    downloadPDF() {
        if (this.DWTObject && this.DWTObject.HowManyImagesInBuffer > 0) {
            this.DWTObject.SaveAllAsPDF("ScannedDocument.pdf", 
                () => console.log("PDF downloaded successfully."),
                (errorCode, errorString) => console.error("Error:", errorString)
            );
        } else {
            console.warn("No scanned image to download.");
        }
    }
}

// Make ScannerControl globally available
window.ScannerControl = ScannerControl;
