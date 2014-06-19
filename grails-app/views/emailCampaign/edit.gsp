<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="campaignName" value="${message(code: 'emailCampaign.label', default: 'Email Campaign')}"/>
    <title><g:message code="crmCampaign.settings.title" args="[campaignName, crmCampaign]"/></title>
    <ckeditor:resources/>
    <r:script>
        var CRM = {
            createEditor: function(id) {
             var editor = CKEDITOR.replace(id,
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
                    filebrowserImageBrowseUrl: "${createLink(controller: 'crmContent', action: 'browse', params: [reference: 'crmCampaign@' + crmCampaign.id, status: 'shared', pattern: 'image'])}",
                    filebrowserImageUploadUrl: "${createLink(controller: 'crmContent', action: 'upload')}"
                });
            return editor;
            },
            applyTemplate: function(oldHtml, newHtml) {
                var $oldDocument = $(oldHtml);
                var $newDocument = $(newHtml);
                // Find all elements in old content with an 'id' attribute.
                $oldDocument.find("[id]").each(function() {
                    var $oldContent = $(this);
                    // Replace same marker (id) in new template with old content.
                    var $newContent = $("#" + this.id, $newDocument);
                    if($newContent.length == 0) {
                        // That id was not found in the new template, append content to the end of template
                        $newDocument.append($oldContent);
                    } else {
                        // Replace placeholder in new template with old content.
                        $newContent.html($oldContent.html());
                    }
                });
                return $newDocument.html();
            }
        };

        $(document).ready(function () {

            CRM.createEditor("bodycontent");

            $("#templates a").click(function(e) {
                e.preventDefault();
                if(confirm("${message(code: 'emailCampaign.template.change.confirm')} " + $(this).text())) {
                    var path = $(this).attr('href');
                    $.getJSON("${createLink(action: 'template')}", {path: path}, function(data) {
                        CKEDITOR.instances.bodycontent.setData(CRM.applyTemplate(CKEDITOR.instances.bodycontent.getData(), data.body));
                    });
                }
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

<g:form name="mainForm">

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

        </div>

        <div class="span4">

            <div class="control-group">
                <label class="control-label">Avsändarens e-postadress</label>

                <div class="controls">
                    <g:textField name="sender" value="${cfg.sender}" class="span11"/>
                </div>
            </div>

        </div>

        <div class="span4">

            <div class="control-group">
                <label class="control-label">Avsändarens namn</label>

                <div class="controls">
                    <g:textField name="senderName" value="${cfg.senderName}" class="span11"/>
                </div>
            </div>

        </div>

    </div>

    <div class="row-fluid">
        <input type="hidden" name="parts" value="body"/>
        <g:textArea id="bodycontent" name="body" value="${cfg.body}" cols="70" rows="18"
                    class="span11 crm-editor-html"/>
    </div>

    <div class="form-actions btn-toolbar">
        <crm:button action="edit" visual="warning" icon="icon-ok icon-white" label="crmCampaign.button.save.label"/>
        <crm:button action="preview" visual="info" icon="icon-eye-open icon-white"
                    label="emailCampaign.button.preview.label"/>
        <g:if test="${metadata.templates}">
            <div class="btn-group">
                <a class="btn btn-success dropdown-toggle" data-toggle="dropdown" href="#">
                    <i class="icon-file icon-white"></i>
                    Välj mall
                    <span class="caret"></span>
                </a>
                <ul class="dropdown-menu" id="templates">
                    <g:each in="${metadata.templates}" var="t">
                        <li><a href="${t.path}">${t.name.encodeAsHTML()}</a></li>
                    </g:each>
                </ul>
            </div>
        </g:if>
        <crm:button type="link" controller="crmCampaign" action="show" id="${crmCampaign.id}" icon="icon-remove"
                    label="crmCampaign.button.close.label"/>
    </div>

</g:form>

</body>
</html>
