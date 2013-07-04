<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmCampaign.label', default: 'Campaign')}"/>
    <title><g:message code="crmCampaign.edit.title" args="[entityName, crmCampaign]"/></title>
    <r:require modules="datepicker,autocomplete,aligndates"/>
    <r:script>
        $(document).ready(function () {

            $('#startDate').closest('.date').datepicker({weekStart: 1}).on('changeDate', function (ev) {
                alignDates($("#startDate"), $("#endDate"), false, ".date");
            });
            $("#startDate").blur(function (ev) {
                alignDates($(this), $("#endDate"), false, ".date");
            });
            $('#endDate').closest('.date').datepicker({weekStart: 1}).on('changeDate', function (ev) {
                alignDates($("#endDate"), $("#startDate"), true, ".date");
            });
            $("#endDate").blur(function (ev) {
                alignDates($(this), $("#startDate"), true, ".date");
            });
        });
    </r:script>
</head>

<body>

<crm:header title="crmCampaign.edit.title"
            subtitle="${message(code: crmCampaign.handlerName + '.label', default: crmCampaign.handlerName)}"
            args="[entityName, crmCampaign]"/>

<g:hasErrors bean="${crmCampaign}">
    <crm:alert class="alert-error">
        <ul>
            <g:eachError bean="${crmCampaign}" var="error">
                <li <g:if test="${error in org.springframework.validation.FieldError}">data-field-id="${error.field}"</g:if>><g:message
                        error="${error}"/></li>
            </g:eachError>
        </ul>
    </crm:alert>
</g:hasErrors>

<g:form>

    <g:hiddenField name="id" value="${crmCampaign.id}"/>
    <g:hiddenField name="version" value="${crmCampaign.version}"/>

    <f:with bean="crmCampaign">

        <div class="row-fluid">

            <div class="span4">
                <div class="row-fluid">
                    <g:if test="${crmCampaign.handlerName}">
                        <div class="control-group">
                            <label class="control-label"><g:message code="crmCampaign.handlerName.label"
                                                                    default="Type"/></label>

                            <div class="controls">
                                <h2>${message(code: crmCampaign.handlerName + '.label', default: crmCampaign.handlerName)}</h2>
                            </div>
                        </div>
                    </g:if>
                    <f:field property="name" input-class="span11" input-autofocus=""/>
                    <f:field property="description">
                        <g:textArea name="description" value="${crmCampaign.description}" rows="5" cols="50"
                                    class="span11"/>
                    </f:field>
                </div>
            </div>

            <div class="span4">
                <div class="row-fluid">
                    <div class="control-group">
                        <label class="control-label"><g:message code="crmCampaign.startTime.label"/></label>

                        <div class="controls">
                            <span class="input-append date"
                                  data-date="${formatDate(format: 'yyyy-MM-dd', date: crmCampaign.startTime ?: new Date())}">
                                <g:textField name="startDate" class="span10" size="10"
                                             placeholder="ÅÅÅÅ-MM-DD"
                                             value="${formatDate(format: 'yyyy-MM-dd', date: crmCampaign.startTime)}"/><span
                                    class="add-on"><i class="icon-th"></i></span>
                            </span>
<%--
                            <g:select name="startTime" from="${timeList}"
                                      value="${formatDate(format: 'HH:mm', date: crmCampaign.startTime)}"
                                      class="span4"/>
--%>
                        </div>
                    </div>

                    <div class="control-group">
                        <label class="control-label"><g:message code="crmCampaign.endTime.label"/></label>

                        <div class="controls">
                            <span class="input-append date"
                                  data-date="${formatDate(format: 'yyyy-MM-dd', date: crmCampaign.endTime ?: new Date())}">
                                <g:textField name="endDate" class="span10" size="10" placeholder="ÅÅÅÅ-MM-DD"
                                             value="${formatDate(format: 'yyyy-MM-dd', date: crmCampaign.endTime)}"/><span
                                    class="add-on"><i class="icon-th"></i></span>
                            </span>
<%--
                            <g:select name="endTime" from="${timeList}"
                                      value="${formatDate(format: 'HH:mm', date: crmCampaign.endTime)}"
                                      class="span4"/>
--%>
                        </div>
                    </div>
                    <f:field property="status">
                        <g:select name="status.id" from="${statusList}" optionKey="id" value="${crmCampaign.statusId}"/>
                    </f:field>

                </div>
            </div>

            <div class="span4">
                <div class="row-fluid">
                    <f:field property="number" input-class="input-small"/>
                    <f:field property="code" input-class="input-small"/>

                    <f:field property="parent">
                        <g:select name="parent.id" from="${parentList}" optionKey="id" value="${crmCampaign.parentId}"/>
                    </f:field>
                </div>
            </div>

        </div>

        <div class="form-actions">
            <crm:button action="edit" visual="primary" icon="icon-ok icon-white" label="crmCampaign.button.save.label"/>
        </div>

    </f:with>

</g:form>

</body>
</html>
