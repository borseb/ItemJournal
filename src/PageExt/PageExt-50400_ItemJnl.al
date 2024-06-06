pageextension 50400 ItemJnl extends "Item Journal"
{

    layout
    {

        addafter(Description)
        {
            field("Approval Status"; Rec."Approval Status")
            {
                ApplicationArea = All;
            }
            field("Approval Date"; Rec."Approval Date")
            {

            }
        }

    }

    actions
    {

        addfirst(Processing)
        {
            group("Request Approval")
            {
                action(Approvals)
                {
                    AccessByPermission = TableData "Approval Entry" = R;
                    ApplicationArea = Suite;
                    Caption = 'Approvals';
                    Image = Approvals;
                    ToolTip = 'View a list of the records that are waiting to be approved. For example, you can see who requested the record to be approved, when it was sent, and when it is due to be approved.';

                    trigger OnAction()
                    begin
                        ApprovalsMgmt.OpenApprovalEntriesPage(Rec.RecordId);
                    end;
                }
                action(Approve)
                {
                    Visible = false;        //PCPL-25/240323
                    image = Approval;
                    Promoted = true;
                    PromotedCategory = process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ApplicationArea = All;
                    trigger OnAction()
                    begin
                        ApprovalsMgmt.ApproveRecordApprovalRequest(Rec.RecordId);
                    end;
                }
                action(Reopen)
                {
                    ApplicationArea = All;
                    Caption = 'Reopen';
                    Image = ReOpen;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    Visible = false;        //PCPL-25/240323
                    trigger OnAction()
                    var
                        ItemJnl: Record "Item Journal Line";
                    begin
                        ItemJnl.Reset();
                        ItemJnl.SetRange("No.", rec."No.");
                        ItemJnl.SetRange("Approval Status", ItemJnl."Approval Status"::Released);
                        IF ItemJnl.FindFirst() then begin
                            ItemJnl."Approval Status" := ItemJnl."Approval Status"::Open;
                            ItemJnl.Modify();
                        end;
                    end;
                }
                // action(Release)
                // {
                //     ApplicationArea = All;
                //     Caption = 'Release';
                //     Image = ReleaseDoc;
                //     Promoted = true;
                //     PromotedCategory = Process;
                //     PromotedOnly = true;
                //     Visible = false;        //PCPL-25/240323
                //     trigger OnAction()
                //     var
                //         ItemJnl: Record "RFQ Header";
                //         WorKflow: Record Workflow;
                //     begin

                //         IF WorKflow.Get('RFQ') then begin
                //             IF WorKflow.Enabled = true then
                //                 Error(NoworkFlowEnableErr);

                //             ItemJnl.Reset();
                //             ItemJnl.SetRange("No.", rec."No.");
                //             ItemJnl.SetRange("Approval Status", ItemJnl."Approval Status"::Open);
                //             IF ItemJnl.FindFirst() then begin
                //                 ItemJnl."Approval Status" := ItemJnl."Approval Status"::Released;
                //                 ItemJnl.Modify();
                //             end;
                //         end;
                //     end;
                // }
                action(SendApprovalRequest)
                {
                    ApplicationArea = All;
                    Caption = 'Send A&pproval Request';
                    Enabled = NOT OpenApprovalEntriesExist AND CanRequestApproavlForFlow;
                    Image = SendApprovalRequest;
                    ToolTip = 'Request approval of the document.';
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;

                    trigger OnAction()
                    var
                        AppEntr: Record "Approval Entry";
                        ItemJnl: Record "Item Journal Line";
                    begin
                        if ApprovalsMgmtCut.CheckItemJnlApprovalWorkflowEnable(Rec) then
                            ApprovalsMgmtCut.OnSendItemJnlForApproval(Rec);


                        //
                        //  IF rec."Approval Status" = rec."Approval Status"::"Pending Approval" then begin
                        // AppEntr.Reset();
                        // AppEntr.SetRange("Document No.", Rec."No.");
                        // IF AppEntr.FindSet() then
                        //     repeat
                        //         Rec.CalcFields("Total Amount");
                        //         AppEntr.Amount := Rec."Total Amount";
                        //         AppEntr."Amount (LCY)" := rec."Total Amount";
                        //         AppEntr.Modify();
                        //     until AppEntr.Next() = 0;
                        // end;
                    end;
                }
                action(CancelApprovalRequest)
                {
                    ApplicationArea = All;
                    Caption = 'Cancel A&pproval Request';
                    Enabled = CancelAppEnable;//CanCancelApprovalForRecord AND CanCancelApprovalForFlow;
                    Image = CancelApprovalRequest;
                    ToolTip = 'Request approval of the document.';
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    trigger OnAction()
                    var
                        ItemJnl: Record "Item Journal Line";
                    begin
                        ApprovalsMgmtCut.OnCancelItemJnlForApproval(rec);
                        // //PCPL-25/240323
                        // ItemJnl.Reset();
                        // ItemJnl.SetRange("No.", rec."No.");
                        // ItemJnl.SetRange("Approval Status", ItemJnl."Approval Status"::"Pending Approval");
                        // IF ItemJnl.FindFirst() then begin
                        //     ItemJnl."Approval Status" := ItemJnl."Approval Status"::Open;
                        //     ItemJnl.Modify();
                        // end;
                        // //PCPL-25/240323                        
                    end;

                }
            }
        }

    }
    trigger OnAfterGetRecord()
    begin
        OpenApprovalEntriesExistForCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
        CanCancelApprovalForRecord := ApprovalsMgmt.CanCancelApprovalForRecord(Rec.RecordId);
        WorkflowWebhookMgt.GetCanRequestAndCanCancel(Rec.RecordId, CanRequestApproavlForFlow, CanCancelApprovalForFlow);

        IF (rec."Approval Status" = rec."Approval Status"::"Pending Approval") then begin
            CancelAppEnable := true;
        end;
        if (rec."Approval Status" = rec."Approval Status"::Released) then begin
            CancelAppEnable := false;
        end;
    end;

    trigger OnOpenPage()
    begin
        IF (rec."Approval Status" = rec."Approval Status"::"Pending Approval") then begin
            CancelAppEnable := true;
        end;
        if (rec."Approval Status" = rec."Approval Status"::Released) then begin
            CancelAppEnable := false;
        end;

    end;


    var
        ApprovalsMgmt: Codeunit 1535;
        ApprovalsMgmtCut: Codeunit 50400;
        WorkflowWebhookMgt: Codeunit 1543;
        OpenApprovalEntriesExistForCurrUser: Boolean;
        OpenApprovalEntriesExist: Boolean;
        CanCancelApprovalForRecord: Boolean;
        CanCancelApprovalForFlow: Boolean;
        CanRequestApproavlForFlow: Boolean;
        NoworkFlowEnableErr: Label 'Workflow is enabled you can not release the order.';
        CancelAppEnable: Boolean;
        Myint: Page 8885;
}