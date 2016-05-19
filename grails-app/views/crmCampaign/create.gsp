<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="entityName" value="${message(code: 'crmCampaign.label', default: 'Campaign')}"/>
    <title><g:message code="crmCampaign.create.title" args="[entityName]"/></title>
    <r:require modules="datepicker,autocomplete,aligndates"/>
    <r:script>
        $(document).ready(function () {
            <crm:datepicker selector="#startDateContainer">.on('changeDate', function (ev) {
                            alignDates($("#startDate"), $("#endDate"), false, ".date")})</crm:datepicker>
            $("#startDate").blur(function (ev) {
                alignDates($(this), $("#endDate"), false, ".date");
            });
            <crm:datepicker selector="#endDateContainer">.on('changeDate', function (ev) {
                alignDates($("#endDate"), $("#startDate"), true, ".date")})</crm:datepicker>
            $("#endDate").blur(function (ev) {
                alignDates($(this), $("#startDate"), true, ".date");
            });
        });
    </r:script>
</head>

<body>

<crm:header title="crmCampaign.create.title" args="[entityName]"/>

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

<g:form action="create">

    <f:with bean="crmCampaign">
        <div class="row-fluid">

            <div class="span4">
                <div class="row-fluid">
                    <f:field property="handlerName">
                        <g:select name="handlerName" from="${campaignTypes}" class="span10"
                                  optionValue="${{ message(code: it + '.label', default: it) }}"/>
                    </f:field>
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
                            <span id="startDateContainer" class="input-append date">
                                <g:textField name="startDate" class="span10" size="10"
                                             placeholder="ÅÅÅÅ-MM-DD"
                                             value="${formatDate(format: 'yyyy-MM-dd', date: crmCampaign.startTime)}"/><span
                                    class="add-on"><i class="icon-th"></i></span>
                            </span>

                            <g:select name="startTime" from="${timeList}"
                                      value="${formatDate(format: 'HH:mm', date: crmCampaign.startTime)}"
                                      noSelection="${['': '']}" class="span4"/>
                        </div>
                    </div>

                    <div class="control-group">
                        <label class="control-label"><g:message code="crmCampaign.endTime.label"/></label>

                        <div class="controls">
                            <span id="endDateContainer" class="input-append date">
                                <g:textField name="endDate" class="span10" size="10" placeholder="ÅÅÅÅ-MM-DD"
                                             value="${formatDate(format: 'yyyy-MM-dd', date: crmCampaign.endTime)}"/><span
                                    class="add-on"><i class="icon-th"></i></span>
                            </span>

                            <g:select name="endTime" from="${timeList}"
                                      value="${formatDate(format: 'HH:mm', date: crmCampaign.endTime)}"
                                      noSelection="${['': '']}" class="span4"/>
                        </div>
                    </div>

                </div>
            </div>

            <div class="span4">
                <div class="row-fluid">
                    <f:field property="number">
                        <g:textField name="number" value="${crmCampaign.number}" class="input-small"/>
                    </f:field>
                    <f:field property="code" input-class="input-small"/>

                    <f:field property="parent">
                        <g:select name="parent.id" from="${parentList}" optionKey="id" value="${crmCampaign.parentId}"
                                  noSelection="${['null': '']}"/>
                    </f:field>

                    <f:field property="username">
                        <g:select name="username" from="${userList}" optionKey="username" optionValue="name"
                                  value="${crmCampaign.username}" class="span11"/>
                    </f:field>
                </div>
            </div>

        </div>

        <div class="form-actions">
            <crm:button visual="success" icon="icon-ok icon-white" label="crmCampaign.button.save.label"/>
            <crm:button type="link" action="index" icon="icon-remove" label="crmCampaign.button.back.label"/>
        </div>

    </f:with>

</g:form>

</body>
</html>
