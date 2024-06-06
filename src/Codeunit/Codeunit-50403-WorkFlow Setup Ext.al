codeunit 50403 "Workflow Setup Ext"
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Setup", 'OnAddWorkflowCategoriesToLibrary', '', true, true)]
    local procedure OnAddWorkflowCategoriesToLibrary()
    begin
        WorkflowSetup.InsertWorkflowCategory(ItemJnlworkflowCategoryTxt, ItemJnlworkflowCategoryDescTxt);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Setup", 'OnAfterInsertApprovalsTableRelations', '', true, true)]
    local procedure OnAfterInsertApprovalsTableRelations()
    var
        ApprovalEntry: Record 454;
    begin
        WorkflowSetup.InsertTableRelation(Database::"Item Journal Line", 0, Database::"Approval Entry", ApprovalEntry.FieldNo("Record ID to Approve"));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Setup", 'OnInsertWorkflowTemplates', '', true, true)]
    local procedure OnInsertWorkflowTemplates()
    var
    begin
        InsertItemJnlApprovalWorkflowTemplate();
    end;

    local procedure InsertItemJnlApprovalWorkflowTemplate()
    var
        Workflow: Record 1501;
    begin
        WorkflowSetup.InsertWorkflowTemplate(Workflow, ItemJnlApprovalWorkflowCodeTxt, ItemJnlApprovalWorkflowCodeDescTxt, ItemJnlWorkflowCategoryTxt);
        InsertItemJnlApprovalWorkflowDetails(Workflow);
        WorkflowSetup.MarkWorkflowAsTemplate(Workflow);
    end;

    local procedure InsertItemJnlApprovalWorkflowDetails(var Workflow: Record 1501)
    var
        WorkflowStepArgument: Record 1523;
        BlankDateFormula: DateFormula;
        WorkflowEventHandlingCust: Codeunit 50401;
        WorkflowResponseHandling: Codeunit 1521;
        ItemJnl: Record "Item Journal Line";
    begin
        /* Below Functin PopulateWorkflowStepArgument is now removal from older BC 18 onwards. new Function Add InitWorkflowStepArgument now.
        WorkflowSetup.PopulateWorkflowStepArgument(WorkflowStepArgument, WorkflowStepArgument."Approver Type"::Approver,
                            WorkflowStepArgument."Approver Limit Type"::"Direct Approver", 0, '', BlankDateFormula, true);
        */

        //New Function Ass BC Suggested temp Commnented
        WorkflowSetup.InitWorkflowStepArgument(WorkflowStepArgument, WorkflowStepArgument."Approver Type"::Approver,
                            WorkflowStepArgument."Approver Limit Type"::"Direct Approver", 0, '', BlankDateFormula, true);



        WorkflowSetup.InsertDocApprovalWorkflowSteps(
            Workflow,
            BuildItemJnlTypeConditions(ItemJnl."Approval Status"::Open),
            WorkflowEventHandlingCust.RunWorkflowOnSendItemJnlForApprovalCode(),
            BuildItemJnlTypeConditions(ItemJnl."Approval Status"::"Pending Approval"),
            WorkflowEventHandlingCust.RunWorkflowOnCancelItemJnlApprovalCode(),
            WorkflowStepArgument,
            true);



    end;

    local procedure BuildItemJnlTypeConditions(Status: Integer): text
    var
        ItemJnl: record "Item Journal Line";
    begin
        ItemJnl.SetRange("Approval Status", Status);
        Exit(StrSubstNo(ItemJnlTypeCondTxt, WorkflowSetup.Encode(ItemJnl.GetView(false))));
    end;

    var
        WorkflowSetup: Codeunit 1502;
        ItemJnlWorkflowCategoryTxt: TextConst ENU = 'RDW';
        ItemJnlWorkflowCategoryDescTxt: TextConst ENU = 'Item Journal Document';
        ItemJnlApprovalWorkflowCodeTxt: TextConst ENU = 'RAPW';
        ItemJnlApprovalWorkflowCodeDescTxt: TextConst ENU = 'Item Journal Approval Workflow';
        ItemJnlTypeCondTxt: TextConst ENU = '‘<?xml version = “1.0” encoding=”utf-8” standalone=”yes”?><ReportParameters><DataItems><DataItem name=”ItemJnl”>%1</DataItem></DataItems></ReportParameters>';
}