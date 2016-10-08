<%@ page import="org.apache.commons.io.FilenameUtils" %>
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
                    customConfig: "${resource(dir: 'js', file: 'crm-ckeditor-config.js', plugin: 'crm-content-ui')}",
                    stylesSet: "crm-no-styles:${resource(dir: 'js', file: 'crm-ckeditor-styles.js', plugin: 'crm-content-ui')}",
                    baseHref: "${createLink(controller: 'static')}",
                    filebrowserBrowseUrl: "${createLink(controller: 'crmContent', action: 'browse', params: [reference: 'crmCampaign@' + crmCampaign.id, status: 'shared'])}",
                    filebrowserUploadUrl: "${createLink(controller: 'crmContent', action: 'upload')}",
                    filebrowserImageBrowseUrl: "${createLink(controller: 'crmContent', action: 'browse', params: [pattern: 'image', reference: 'crmCampaign@' + crmCampaign.id, status: 'shared', pattern: 'image'])}",
                    filebrowserImageUploadUrl: "${createLink(controller: 'crmContent', action: 'upload')}"
                });
            return editor;
            },

            addPart: function() {
                $.post("${createLink(action: 'edit')}", $('#mainForm').serialize(), function(data) {
                    $('#addPartModal').modal('show');
                });
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
                return $('<div/>').append($newDocument).html();
            }
        };

        $(document).ready(function () {

            CRM.createEditor("bodycontent");

            $('.crm-preview').click(function(ev) {
                ev.preventDefault();
                $('#bodycontent').val(CKEDITOR.instances.bodycontent.getData());
                var data = $('#mainForm').serialize() + '&preview=true';
                $.post("${createLink(action: 'edit')}", data, function(html) {
                    $('#preview-container').html(html);
                    $('#previewModal').modal('show');
                });
            });

            $('.crm-part').click(function(ev) {
                var id = $(this).data('crm-id');
                $('input[name="next"]').val(id);
            });

            $('.crm-add').click(function(ev) {
                ev.preventDefault();
                CRM.addPart();
            });

            $('.crm-delete').click(function(ev) {
                ev.preventDefault();
                var part = $(this).data('crm-id');
                if(confirm('Are you sure you want to delete the part?')) {
                    $.post("${createLink(action: 'delete')}", {id: "${crmCampaign.id}", part: part}, function(response) {
                        window.location.href = "${createLink(action: 'edit', id: crmCampaign.id)}";
                    });
                }
            });

            $('#addPartModal form').submit(function(ev) {
                ev.preventDefault();
                var data = $(this).serialize();
                $.post("${createLink(action: 'addPart')}", data, function(response) {
                    window.location.href = "${createLink(action: 'edit', id: crmCampaign.id)}?part=" + response.id;
                });
            });

            $('#addPartModal').on('shown', function () {
                $('input:visible:first', $(this)).focus();
            });

            $('#previewModal').on('hidden', function () {
                $('#preview-container').empty();
                CKEDITOR.instances.bodycontent.focus();
            });

            $("#templates a").click(function(ev) {
                ev.preventDefault();
                if(confirm("${message(code: 'emailCampaign.template.change.confirm')} " + $(this).text())) {
                    var path = $(this).attr('href');
                    $.getJSON("${createLink(action: 'template')}", {path: path}, function(data) {
                        CKEDITOR.instances.bodycontent.setData(CRM.applyTemplate(CKEDITOR.instances.bodycontent.getData(), data.body));
                    });
                }
            });
        });
    </r:script>
    <style type="text/css">
    #previewModal {
        width: 800px;
        margin-left: -370px; /* must be half of the width, minus scrollbar on the left (30px) */
    }
    </style>
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

<g:form name="mainForm" action="edit">

    <g:hiddenField name="id" value="${crmCampaign.id}"/>
    <g:hiddenField name="version" value="${crmCampaign.version}"/>
    <g:hiddenField name="part" value="${part.id}"/>
    <g:hiddenField name="next" value=""/>

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
                <label class="control-label">Avsändarens namn</label>

                <div class="controls">
                    <g:textField name="senderName" value="${cfg.senderName}" class="span11"/>
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

    </div>

    <div class="row-fluid">
        <g:textArea id="bodycontent" name="content" value="${content}" cols="70" rows="18"
                    class="span11 crm-editor-html"/>
    </div>

    <div class="form-actions">
        <crm:button action="edit" visual="warning" icon="icon-ok icon-white" label="crmCampaign.button.save.label"/>

        <a href="#" class="btn btn-info crm-preview">
            <i class="icon-eye-open icon-white"></i>
            <g:message code="emailCampaign.button.preview.label"/>
        </a>

        <g:each in="${metadata.parts}" var="p">
            <div class="btn-group">
                <button type="submit" data-crm-id="${p.id}" class="btn btn-${p.id == part.id ? 'success' : 'info'} crm-part">
                    <i class="icon-th-large icon-white"></i>
                    ${FilenameUtils.getBaseName(p.name)}
                </button>
                <button class="btn btn-${p.id == part.id ? 'success' : 'info'} dropdown-toggle" data-toggle="dropdown">
                    <span class="caret"></span>
                </button>
                <ul class="dropdown-menu">
                    <li><a href="#" class="crm-rename" data-crm-id="${p.id}">Redigera</a></li>
                    <li><a href="#" class="crm-delete" data-crm-id="${p.id}">Ta bort del</a></li>
                    <li><a href="#" class="crm-add">Lägg till del</a></li>
                </ul>
            </div>
        </g:each>
        <crm:button type="link" controller="crmCampaign" action="show" id="${crmCampaign.id}" icon="icon-remove"
                    label="crmCampaign.button.close.label"/>
    </div>

</g:form>

<div id="addPartModal" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel"
     aria-hidden="true">
    <g:form action="addPart">
        <input type="hidden" name="id" value="${crmCampaign.id}"/>

        <div class="modal-header">
            <a class="close" data-dismiss="modal" aria-hidden="true">×</a>

            <h3 id="myModalLabel">Lägg till del</h3>
        </div>

        <div class="modal-body">
            <div class="row-fluid">
                <div class="control-group">
                    <label class="control-label">Namn</label>

                    <div class="controls">
                        <g:textField name="name" value="" class="span6"/>
                    </div>
                </div>
                <g:if test="${metadata.templates}">
                    <div class="control-group">
                        <label class="control-label">Mall</label>

                        <div class="controls">
                            <g:select name="template" from="${metadata.templates}" optionKey="id" optionValue="title" class="span6"/>
                        </div>
                    </div>
                </g:if>
            </div>
        </div>

        <div class="modal-footer">
            <button type="submit" class="btn btn-success">
                <i class="icon-ok icon-white"></i>
                Spara
            </button>
            <a href="#" class="btn" data-dismiss="modal">
                <i class="icon-remove"></i>
                <g:message code="crmEmailCampaign.button.close.label" default="Close"/>
            </a>
        </div>
    </g:form>
</div>

<div id="previewModal" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="previewModalLabel" aria-hidden="true">

    <div class="modal-header">
        <a class="close" data-dismiss="modal" aria-hidden="true">×</a>

        <h3 id="previewModalLabel">${crmCampaign.name}</h3>
    </div>

    <div class="modal-body">
        <div class="row-fluid">
            <div id="preview-container"></div>
        </div>
    </div>

    <div class="modal-footer">
        <g:link mapping="crm-newsletter-anonymous" id="${crmCampaign.publicId}" target="_blank"
        style="margin-right: 15px; font-size: smaller;">
            Öppna på ny sida
        </g:link>
        <a href="#" class="btn" data-dismiss="modal">
            <i class="icon-ok"></i>
            <g:message code="crmEmailCampaign.button.close.label" default="Close"/>
        </a>
    </div>
</div>

</body>
</html>
