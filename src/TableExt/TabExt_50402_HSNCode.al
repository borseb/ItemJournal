tableextension 50402 HSNCodeExt extends "HSN/SAC"
{
    fields
    {
        // Add changes to table fields here
        modify(Code)
        {
            trigger OnBeforeValidate()
            var
                strlength: Integer;
            begin
                strlength := StrLen(Rec.Code);
                if strlength <> 6 then
                    Error('Code should be six character %1', Rec.Code);
            end;
        }
    }

    keys
    {
        // Add changes to keys here
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        myInt: Integer;
}