table 50300 PdfData
{
    Caption = 'PdfData';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; EntryNo; Integer)
        {
            Caption = 'EntryNo';
        }
        field(2; Bas64Data1; Blob)
        {
            Caption = 'Bas64Data1';
        }
        field(3; Bas64Data2; Blob)
        {
            Caption = 'Bas64Data2';
        }
        field(4; SalesOrderNo; Code[20])
        {
            Caption = 'SalesOrderNo';
        }
    }
    keys
    {
        key(PK; EntryNo)
        {
            Clustered = true;
        }
    }
}
