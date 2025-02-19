// codeunit 50300 MergePDF
// {
//     // Add reports or base64 PDFs to the merge list
//     // procedure AddReportToMerge(ReportID: Integer; RecRef: RecordRef)
//     // var
//     //     Tempblob: Codeunit "Temp Blob";
//     //     Ins: InStream;
//     //     Outs: OutStream;
//     //     Parameters: Text;
//     //     Convert: Codeunit "Base64 Convert";
//     // begin
//     //     Tempblob.CreateInStream(Ins);
//     //     Tempblob.CreateOutStream(Outs);
//     //     Parameters := '';
//     //     Report.SaveAs(ReportID, Parameters, ReportFormat::Pdf, Outs, RecRef);

//     //     Clear(JObjectPDFToMerge);
//     //     JObjectPDFToMerge.Add('pdf', Convert.ToBase64(Ins)); // Convert InStream to Base64
//     //     JArrayPDFToMerge.Add(JObjectPDFToMerge); // Add to array
//     // end;

//     // Add an existing base64 PDF to the merge list
//     procedure AddBase64pdf(base64pdf: Text)
//     begin
//         Clear(JObjectPDFToMerge);
//         JObjectPDFToMerge.Add('pdf', base64pdf);
//         JArrayPDFToMerge.Add(JObjectPDFToMerge); // Add to array
//     end;

//     // Clear the list of PDFs to merge
//     procedure ClearPDF()
//     begin
//         Clear(JArrayPDFToMerge);
//     end;

//     // Retrieve the merged PDFs in a JSON array
//     procedure GetJArray() JArrayPDF: JsonArray;
//     begin
//         JArrayPDF := JArrayPDFToMerge;
//     end;

//     // Merge the PDF files (add them as base64 and combine them into one stream)
//     procedure MergePDFs(var MergedInStream: InStream)
//     var
//         TempBlob: Codeunit "Temp Blob";
//         OutStream: OutStream;
//         InStream1: InStream;
//         Base64PDF: Text;
//         Convert: Codeunit "Base64 Convert";
//         MergedOutStream: OutStream;
//         JObjectPDF: JsonObject;  // Declare the JsonObject explicitly
//         JArrayPDF: JsonArray;
//         JsonItem: JsonToken;  // Declare a JsonToken to hold each element in the array
//     begin
//         // Create the final combined output stream
//         TempBlob.CreateOutStream(MergedOutStream);

//         // Iterate through each PDF in the list and append to the final output stream
//         JArrayPDF := JArrayPDFToMerge;  // Get the JSON array
//         foreach JsonItem in JArrayPDF do begin
//             // Cast JsonToken to JsonObject
//             JObjectPDF := JsonItem.AsObject();

//             JObjectPDF.WriteTo(Base64PDF);  // Extract base64 PDF

//             // Convert the base64 to InStream
//             TempBlob.CreateOutStream(OutStream);
//             Convert.FromBase64(Base64PDF, OutStream);
//             TempBlob.CreateInStream(InStream1);

//             // Copy the current InStream to the merged output stream
//             CopyStream(MergedOutStream, InStream1);
//         end;

//         // Set the merged PDF as InStream
//         TempBlob.CreateInStream(MergedInStream);
//     end;


//     // Declare internal variables for merging
//     var
//         JObjectPDFToMerge: JsonObject;
//         JArrayPDFToMerge: JsonArray;
//         JObjectPDF: JsonObject;
// }
