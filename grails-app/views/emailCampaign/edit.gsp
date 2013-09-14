<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="campaignName" value="${message(code: 'emailCampaign.label', default: 'Email Campaign')}"/>
    <title><g:message code="crmCampaign.settings.title" args="[campaignName, crmCampaign]"/></title>
    <ckeditor:resources/>
    <r:script>
        $(document).ready(function () {
            var editor = CKEDITOR.replace('text-html',
            {
                width: '98.3%',
                height: '400px',
                resize_enabled: true,
                startupFocus: true,
                skin: 'kama',
                toolbar: [
                    ['Styles', 'Format', 'Font', 'FontSize'],
                    ['Source'],
                    '/',
                    ['Bold', 'Italic', 'Underline', 'Strike', 'TextColor', 'BGColor', 'RemoveFormat'],
                    ['Paste', 'PasteText', 'PasteFromWord'],
                    ['JustifyLeft', 'JustifyCenter', 'JustifyRight'],
                    ['NumberedList', 'BulletedList', '-', 'Outdent', 'Indent'],
                    ['Image', 'Link', 'Unlink'],
                    ['Table', 'HorizontalRule']
                ],
                basicEntities: false,
                protectedSource: [/\[@link\s+[\s\S]*?\[\/@link\]/g, /\[#[\s\S]*?\]/g],
                baseHref: "${createLink(controller: 'static')}",
                filebrowserBrowseUrl: "${createLink(controller: 'crmContent', action: 'browse', params: [reference: 'crmCampaign@' + crmCampaign.id, status: 'shared'])}",
                filebrowserUploadUrl: "${createLink(controller: 'crmContent', action: 'upload')}",
                filebrowserImageBrowseUrl: "${createLink(controller: 'crmContent', action: 'browse', params: [reference: 'crmCampaign@' + crmCampaign.id, status: 'shared'])}",
                filebrowserImageUploadUrl: "${createLink(controller: 'crmContent', action: 'upload')}"
            });
        });
    </r:script>
</head>

<body>

<crm:header title="crmCampaign.settings.title" args="[campaignName, crmCampaign]"/>

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

<g:form action="edit">

    <g:hiddenField name="id" value="${crmCampaign.id}"/>
    <g:hiddenField name="version" value="${crmCampaign.version}"/>

    <div class="row-fluid">
        <div class="span4">
            <div class="control-group">
                <label class="control-label">Rubrik</label>

                <div class="controls">
                    <g:textField name="subject" value="${cfg.subject ?: crmCampaign.name}" class="span11"/>
                </div>
            </div>

            <div class="control-group">
                <label class="control-label">Avsändare</label>

                <div class="controls">
                    <g:textField name="sender" value="${cfg.sender}" class="span11"/>
                </div>
            </div>

        </div>

        <div class="span4">

            <div class="control-group">
                <label class="control-label">Huvudmall</label>

                <div class="controls">
                    <g:textField name="template" value="${cfg.template}" maxlength="255" class="span11"/>
                </div>
            </div>

            <div class="control-group">
                <label class="control-label">Externt innehåll</label>

                <div class="controls">
                    <g:textField name="external" value="${cfg.external}" maxlength="255" class="span11"/>
                </div>
            </div>
        </div>

        <div class="span4">
        </div>

    </div>

    <div class="tabbable">
        <ul class="nav nav-tabs">
            <li class="active"><a href="#html" data-toggle="tab">Html</a></li>
            <li><a href="#text" data-toggle="tab">Text</a></li>
            <crm:pluginViews location="tabs" var="view">
                <crm:pluginTab id="${view.id}" label="${view.label}" count="${view.model?.totalCount}"/>
            </crm:pluginViews>
        </ul>

        <div class="tab-content">
            <div class="tab-pane active" id="html">

                <div class="row-fluid">
                    <g:textArea id="text-html" name="html" cols="70" rows="18" class="span11" value="${cfg.html}"/>
                </div>

            </div>

            <div class="tab-pane" id="text">

                <div class="row-fluid">
                    <g:textArea id="text-plain" name="text" cols="70" rows="20" class="span11" value="${cfg.text}"/>
                </div>

            </div>
        </div>

    </div>

    <div class="form-actions">
        <crm:button visual="warning" icon="icon-ok icon-white" label="crmCampaign.button.save.label"/>
        <crm:button type="link" controller="crmCampaign" action="show" id="${crmCampaign.id}" icon="icon-remove"
                    label="crmCampaign.button.cancel.label"/>
        <a href="${url}" class="btn btn-info" title="Klicka här för att visa en webbversion" target="preview">
        <i class="icon-eye-open icon-white"></i>
        <g:message code="emailCampaign.button.preview.label" default="Preview"/>
    </a>
    </div>

</g:form>
</body>
</html>
