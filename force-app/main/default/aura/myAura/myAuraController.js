({
    onPageReferenceChanged: function(cmp, event, helper) {
        var assessmentTaskId = cmp.get("v.pageReference").state.c__assessmentTaskId;
        var visitId = cmp.get("v.pageReference").state.c__visitId;
        cmp.set("v.assessmentTaskId",assessmentTaskId);
        cmp.set("v.visitId",visitId);
    },
 })