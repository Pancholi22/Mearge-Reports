// Load required libraries dynamically
const scriptPDFLib = document.createElement("script");
scriptPDFLib.src = "https://cdnjs.cloudflare.com/ajax/libs/pdf-lib/1.17.1/pdf-lib.min.js";
document.head.appendChild(scriptPDFLib);

const scriptXLSX = document.createElement("script");
scriptXLSX.src = "https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js";
document.head.appendChild(scriptXLSX);

const scriptJsPDF = document.createElement("script");
scriptJsPDF.src = "https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js";
document.head.appendChild(scriptJsPDF);

scriptPDFLib.onload = scriptXLSX.onload = scriptJsPDF.onload = function () {
  document.addEventListener("DOMContentLoaded", function () {
    let container = document.createElement("div");
    container.id = "controlAddIn";
    document.body.appendChild(container);

    const mergeButton = document.createElement("button");
    mergeButton.textContent = "Merge Files";
    mergeButton.id = "mergeBtn";
    document.body.appendChild(mergeButton);

    mergeButton.addEventListener("click", function () {
      alert("Waiting for Base64 Data from AL");
    });
  });
};

async function PassData(base64Json) {
  try {
    console.log("Received JSON Data:", base64Json);
    const base64Array = JSON.parse(base64Json);

    if (!Array.isArray(base64Array) || base64Array.length === 0) {
      alert("No valid Base64 data received.");
      return;
    }

    let convertedBase64Array = [];
    for (const base64Data of base64Array) {
      if (isExcelBase64(base64Data)) {
        const pdfBase64 = await convertExcelToPDFBase64(base64Data);
        convertedBase64Array.push(pdfBase64);
      } else if (isImageBase64(base64Data)) {
        const pdfBase64 = await convertImageToPDFBase64(base64Data);
        convertedBase64Array.push(pdfBase64);
      } else {
        convertedBase64Array.push(base64Data);
      }
    }

    mergePDFs(convertedBase64Array);
  } catch (error) {
    console.error("Error processing Base64 JSON:", error.message);
    alert(`Error: ${error.message}`);
  }
}

function isExcelBase64(base64String) {
  return base64String.startsWith("UEsDB") || base64String.startsWith("0M8R4E");
}

function isImageBase64(base64String) {
  return base64String.startsWith("data:image/");
}

async function convertExcelToPDFBase64(base64Excel) {
  try {
    const binaryString = atob(base64Excel);
    const byteArray = new Uint8Array(binaryString.length);
    for (let i = 0; i < binaryString.length; i++) {
      byteArray[i] = binaryString.charCodeAt(i);
    }

    const workbook = XLSX.read(byteArray, { type: "array" });
    const sheetName = workbook.SheetNames[0];
    const worksheet = workbook.Sheets[sheetName];
    const sheetData = XLSX.utils.sheet_to_json(worksheet, { header: 1 });

    const { jsPDF } = window.jspdf;
    const pdf = new jsPDF();

    sheetData.forEach((row, index) => {
      pdf.text(row.join(" "), 10, 10 + index * 10);
    });

    return pdf.output("datauristring").split(",")[1];
  } catch (error) {
    console.error("Error converting Excel to PDF:", error);
    alert("Error converting Excel to PDF.");
    return null;
  }
}

async function convertImageToPDFBase64(base64Image) {
  try {
      const { jsPDF } = window.jspdf;
      let format;

      // Detect MIME type or assume PNG
      if (base64Image.startsWith("data:image/")) {
          format = base64Image.split(';')[0].split('/')[1].toUpperCase();
      } else {
          format = "PNG"; // Default to PNG if format is missing
          base64Image = "data:image/png;base64," + base64Image;
      }

      if (format === "JPEG") format = "JPG"; // Normalize format for jsPDF

      let pdf = new jsPDF();
      let imgProps = pdf.getImageProperties(base64Image);
      let pdfWidth = pdf.internal.pageSize.getWidth();
      let pdfHeight = (imgProps.height * pdfWidth) / imgProps.width;

      pdf.addImage(base64Image, format, 0, 0, pdfWidth, pdfHeight);

      // Convert to Base64 using UTF-8 encoding
      const pdfBytes = pdf.output("arraybuffer");
      const utf8EncodedBase64 = btoa(new TextDecoder("utf-8").decode(new Uint8Array(pdfBytes)));

      return utf8EncodedBase64; // Return UTF-8 encoded Base64 PDF
  } catch (error) {
      console.error("Error converting Image to PDF:", error);
      alert("Error converting Image to PDF.");
      return null;
  }
}


async function mergePDFs(base64Array) {
  try {
    const mergedPdf = await PDFLib.PDFDocument.create();

    for (let base64 of base64Array) {
      await addBase64ToPDF(mergedPdf, base64);
    }

    const mergedPdfBytes = await mergedPdf.save();
    downloadPDF(mergedPdfBytes);
  } catch (error) {
    console.error("Error merging PDFs:", error);
    alert("An error occurred while merging PDFs.");
  }
}

async function addBase64ToPDF(mergedPdf, base64String) {
  try {
    // Ensure the Base64 string is valid
    if (!base64String || typeof base64String !== "string") {
      throw new Error("Invalid Base64 input.");
    }

    // Sanitize and decode Base64
    const sanitizedBase64 = base64String.replace(/\s+/g, "").replace(/[^A-Za-z0-9+/=]/g, "");
    const byteArray = new Uint8Array(
      atob(sanitizedBase64)
        .split("")
        .map((char) => char.charCodeAt(0))
    );

    // Load the PDF from the decoded bytes
    const pdfDoc = await PDFLib.PDFDocument.load(byteArray);

    // Copy pages from the loaded PDF into the merged PDF
    const pages = await mergedPdf.copyPages(pdfDoc, pdfDoc.getPageIndices());
    pages.forEach((page) => mergedPdf.addPage(page));

    console.log("Added Base64 PDF successfully.");
  } catch (error) {
    console.error("Error processing Base64 PDF:", error);
    alert("Failed to process a Base64 PDF. Ensure the data is valid.");
  }
}


function downloadPDF(pdfBytes) {
  const blob = new Blob([pdfBytes], { type: "application/pdf" });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = "merged.pdf";
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  URL.revokeObjectURL(url);
}



// // Load PDF-lib from CDN dynamically
// const script = document.createElement("script");
// script.src = "https://cdnjs.cloudflare.com/ajax/libs/pdf-lib/1.17.1/pdf-lib.min.js";
// document.head.appendChild(script);

// script.onload = function () {
//   document.addEventListener("DOMContentLoaded", function () {
//     // Create the main container
//     let container = document.createElement("div");
//     container.id = "controlAddIn";
//     document.body.appendChild(container);

//     // Create a button to trigger the merging process
//     const mergeButton = document.createElement("button");
//     mergeButton.textContent = "Merge PDFs";
//     mergeButton.id = "mergeBtn";
//     document.body.appendChild(mergeButton);

//     // Add event listener to the merge button
//     mergeButton.addEventListener("click", function () {
//       // Call PassData when button is clicked with example Base64 data
//       // Replace this with your actual Base64 data for testing
//       const Base64Part1 = "your_first_base64_string_here";
//       const Base64Part2 = "your_second_base64_string_here";

//       PassData(Base64Part1, Base64Part2);
//     });
//   });
// };

// // Modify PassData to process and display both Base64 parts separately and merge them
// function PassData(Base64Part1, Base64Part2) {
//   try {
//     console.log("Received Data:", Base64Part1, Base64Part2);

//     const container = document.getElementById("controlAddIn");
//     container.innerHTML = ""; // Clear previous content

//     // Check if both Base64 parts exist
//     if (!Base64Part1 || !Base64Part2) {
//       alert("Both Base64 parts are required.");
//       return;
//     }

//     // Merge the two Base64 PDF parts
//     mergePDFs(Base64Part1, Base64Part2);

//   } catch (error) {
//     console.error("Error:", error.message);
//     alert(`Error: ${error.message}`);
//   }
// }

// // Function to merge the Base64 PDFs
// async function mergePDFs(base64Part1, base64Part2) {
//   try {
//     // Convert Base64 parts to byte arrays
//     const mergedPdf = await PDFLib.PDFDocument.create();

//     await addBase64ToPDF(mergedPdf, base64Part1);
//     await addBase64ToPDF(mergedPdf, base64Part2);

//     // Save and download the merged PDF
//     const mergedPdfBytes = await mergedPdf.save();
//     downloadPDF(mergedPdfBytes);

//   } catch (error) {
//     console.error("Error merging PDFs:", error);
//     alert("An error occurred while merging PDFs.");
//   }
// }

// // Function to convert Base64 to PDF and add it to the merged document
// // Function to convert Base64 to PDF and add it to the merged document
// async function addBase64ToPDF(mergedPdf, base64String) {
//   try {
//     // Remove unwanted characters from MSDOS encoding
//     const sanitizedBase64 = base64String
//       .replace(/\s+/g, '') // Remove spaces and newlines
//       .replace(/[^A-Za-z0-9+/=]/g, ''); // Remove non-Base64 characters

//     // Decode Base64 safely
//     const byteArray = Uint8Array.from(atob(sanitizedBase64), c => c.charCodeAt(0));

//     // Load PDF and merge
//     const pdfDoc = await PDFLib.PDFDocument.load(byteArray);
//     const pages = await mergedPdf.copyPages(pdfDoc, pdfDoc.getPageIndices());
//     pages.forEach(page => mergedPdf.addPage(page));
//   } catch (error) {
//     console.error("Invalid Base64 PDF:", error);
//     alert("Error processing a Base64 input. Ensure the data is valid.");
//   }
// }


// // Function to download the merged PDF
// function downloadPDF(pdfBytes) {
//   const blob = new Blob([pdfBytes], { type: "application/pdf" });
//   const url = URL.createObjectURL(blob);
//   const a = document.createElement("a");
//   a.href = url;
//   a.download = "merged.pdf";
//   document.body.appendChild(a);
//   a.click();
//   document.body.removeChild(a);
//   URL.revokeObjectURL(url);
// }
