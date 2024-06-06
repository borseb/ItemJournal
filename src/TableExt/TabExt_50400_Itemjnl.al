tableextension 50400 ItemJnl extends "Item Journal Line"
{
    fields
    {
        // Add changes to table fields here
        // modify(Status)
        // {

        //     OptionCaption = 'Open,Released,Pending Approval';
        //     OptionMembers = Open,Released,"Pending Approval";

        // }
        field(50300; "Approval Status"; Enum "Transfer Document Status")
        {

        }
        field(50301; "Approval Date"; Date)
        {

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