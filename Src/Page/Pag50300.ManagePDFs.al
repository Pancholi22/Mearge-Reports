page 50300 "Manage PDFs"
{
    ApplicationArea = All;
    Caption = 'Manage PDFs';
    PageType = CardPart;

    layout
    {
        area(Content)
        {
            usercontrol(controllAddin; ControllAddin)
            {
                ApplicationArea = All;
                trigger StartAddin()
                begin
                    CurrPage.ControllAddin.PassData(ConvertListToJsonString(Base64List));
                end;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(DownloadAttachments)
            {
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;

                trigger OnAction()
                var
                    Instream: InStream;
                    TypeHelper: Codeunit "Type Helper";
                    PdfData_lRec: Record PdfData;
                    SalesOrder: Page "Sales Order";
                    AttachDocuments: Record "Document Attachment";
                    TenantMedia: Record "Tenant Media";
                    Base64CodeUnit: Codeunit "Base64 Convert";
                    // Base64List: List of [Text];
                    Base64Data: Text;
                begin
                    // Message to confirm the action is triggered
                    Message('Passing Base64 Data');
                    Clear(Base64List);
                    if PdfData_lRec.get(1) then begin
                        SalesOrder.InsertData(PdfData_lRec.SalesOrderNo);
                        AttachDocuments.Reset();
                        AttachDocuments.SetRange("Table ID", 36);
                        AttachDocuments.SetRange("No.", PdfData_lRec.SalesOrderNo);

                        if AttachDocuments.FindSet() then begin
                            repeat
                                TenantMedia.Reset();
                                TenantMedia.SetRange(ID, AttachDocuments."Document Reference ID".MediaId);

                                if TenantMedia.FindFirst() then begin
                                    TenantMedia.CalcFields(Content);
                                    TenantMedia.Content.CreateInStream(Instream, TextEncoding::UTF8);
                                    Base64Data := Base64CodeUnit.ToBase64(Instream, false);
                                    Base64List.Add(Base64Data);
                                    Message(Base64Data);
                                end;
                            until AttachDocuments.Next() = 0;
                        end;

                        CurrPage.ControllAddin.PassData(ConvertListToJsonString(Base64List));
                    end;
                end;
            }

            action(MeargeReports)
            {
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;

                trigger OnAction()
                var
                    Instream1: InStream;
                    Instream2: InStream;
                    TypeHelper: Codeunit "Type Helper";
                    PdfData_lRec: Record PdfData;
                    SalesOrder: Page "Sales Order";
                    AttachDocuments: Record "Document Attachment";
                    TenantMedia: Record "Tenant Media";
                    Bas64CodeUNit: Codeunit "Base64 Convert";
                begin
                    // Message to confirm the action is triggered
                    Message('Passing Base64 Data');
                    Clear(PdfData_lRec);
                    if PdfData_lRec.get(1) then begin
                        SalesOrder.InsertData(PdfData_lRec.SalesOrderNo);

                        PdfData_lRec.CalcFields(Bas64Data1);
                        PdfData_lRec.Bas64Data1.CreateInStream(Instream1, TextEncoding::UTF8);
                        Base64Part1 := TypeHelper.ReadAsTextWithSeparator(Instream1, TypeHelper.LFSeparator());

                        Clear(TypeHelper);
                        PdfData_lRec.CalcFields(Bas64Data2);
                        PdfData_lRec.Bas64Data2.CreateInStream(Instream2, TextEncoding::UTF8);
                        Base64Part2 := TypeHelper.ReadAsTextWithSeparator(Instream2, TypeHelper.LFSeparator());

                        // CurrPage.controllAddin.PassData(Base64Part1, Base64Part2);
                    end;
                end;
            }
        }
    }

    procedure GetBase64Data(Base64Data1: Text; Base64Data2: Text; SalesHeader: Record "Sales Header"; SalesOrderNo_iRec: Code[20])
    var
        OutStream1: OutStream;
        OutStream2: OutStream;
    begin
        // Assign the parts of the Base64 data
        Base64Part1 := Base64Data1;
        Base64Part2 := Base64Data2;
        PdfData.DeleteAll();
        // CurrPage.controllAddin.PassData(Base64Part1, Base64Part2);
        PdfData.SetRange(SalesOrderNo, SalesOrderNo_iRec);
        if PdfData.FindFirst() then begin
            PdfData.DeleteAll();
            PdfData.Init();
            PdfData.SalesOrderNo := SalesOrderNo_iRec;
            PdfData.EntryNo := 1;
            PdfData.Bas64Data1.CreateOutStream(OutStream1, TextEncoding::UTF8);
            OutStream1.WriteText(Base64Data1);
            PdfData.Bas64Data2.CreateOutStream(OutStream2, TextEncoding::UTF8);
            OutStream2.WriteText(Base64Data2);
            PdfData.Insert(true);
            Commit();
        end
        else begin
            PdfData.DeleteAll();
            PdfData.Init();
            PdfData.SalesOrderNo := SalesOrderNo_iRec;
            PdfData.EntryNo := 1;
            PdfData.Bas64Data1.CreateOutStream(OutStream1, TextEncoding::UTF8);
            OutStream1.WriteText(Base64Data1);
            PdfData.Bas64Data2.CreateOutStream(OutStream2, TextEncoding::UTF8);
            OutStream2.WriteText(Base64Data2);
            PdfData.Insert();
            Commit();
        end;
    end;

    procedure ConvertListToJsonString(Base64List: List of [Text]): Text
    var
        JsonArray: JsonArray;
        JsonValue: JsonValue;
        Base64Text: Text;
    // Data: Text;
    begin
        foreach Base64Text in Base64List do begin
            JsonValue.SetValue(Base64Text);
            JsonArray.Add(JsonValue);
        end;

        JsonArray.WriteTo(Data);
        exit(Data);
    end;

    var
        Base64Part1: Text;
        Base64Part2: Text;
        PdfData: Record PdfData;
        Base64List: List of [Text];
        Data: Text;
}
