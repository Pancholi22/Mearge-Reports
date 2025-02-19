const express = require('express');
const { PDFDocument } = require('pdf-lib');
const bodyParser = require('body-parser');
const fs = require('fs');

const app = express();
const PORT = 3000;

// Middleware to parse JSON requests
app.use(bodyParser.json({ limit: '50mb' }));

// Convert Base64 to PDF Buffer
async function base64ToPDF(base64) {
    return Buffer.from(base64, 'base64');
}

// Merge PDFs
async function mergePDFs(base64Files) {
    const mergedPdf = await PDFDocument.create();

    for (const base64 of base64Files) {
        const pdfBytes = await base64ToPDF(base64);
        const pdfToAdd = await PDFDocument.load(pdfBytes);
        const copiedPages = await mergedPdf.copyPages(pdfToAdd, pdfToAdd.getPageIndices());
        copiedPages.forEach(page => mergedPdf.addPage(page));
    }

    return await mergedPdf.save();
}

// API Endpoint to merge PDFs
app.post('/merge', async (req, res) => {
    try {
        const { files } = req.body; // Expecting an array of Base64 PDFs
        if (!files || !Array.isArray(files) || files.length === 0) {
            return res.status(400).json({ error: "No valid PDF files provided" });
        }

        const mergedPdfBytes = await mergePDFs(files);
        const filePath = `merged_output.pdf`;
        fs.writeFileSync(filePath, mergedPdfBytes);

        res.download(filePath, 'merged.pdf', () => {
            fs.unlinkSync(filePath); // Delete the file after download
        });

    } catch (error) {
        console.error("Error merging PDFs:", error);
        res.status(500).json({ error: "Internal Server Error" });
    }
});

// Start the server
app.listen(PORT, () => {
    console.log(`🚀 Server is running at http://localhost:${PORT}`);
});
