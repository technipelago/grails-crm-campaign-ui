<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main">
    <g:set var="campaignName" value="${message(code: 'emailCampaign.label', default: 'Email Campaign')}"/>
    <title><g:message code="crmCampaign.settings.title" args="[campaignName, crmCampaign]"/></title>
    <r:require module="autocomplete"/>
    <ckeditor:resources/>
    <r:script>
        function createEditor(id) {
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
        }

        function addPart(p, value, activate) {
            var $ul = $("#content-container ul.nav-tabs");
            var $content = $("#content-container div.tab-content");
            var $a = $('a[href="#' + p + '"]', $ul);

            if(!$a.length) {
                var $last = $("#content-container ul.nav-tabs > li:last");
                $a = $('<a href="#' + p + '" data-toggle="tab">' + p + '</a>');
                var $li = $("<li/>");
                $li.append($a);
                if($last.length) {
                    $li.insertBefore($last);
                } else {
                    $ul.append($li);
                }
                var $panel = $('<div/>');
                $panel.attr('id', p);
                $panel.addClass("tab-pane");
                var $hidden = $('<input type="hidden" name="parts"/>');
                $hidden.val(p);
                $panel.append($hidden);
                var $input = $('<textarea id="'
                + p
                + '-content" name="'
                + p
                + '" cols="70" rows="18" class="span11"/>');
                $input.val(value);
                $panel.append($input);
                $content.append($panel);
                var editor = createEditor(p + '-content');
            }
            if(activate) {
                $a.tab('show');
            }
            return $a;
        }

        function deletePart(p) {

            // Delete CKEditor instance
            var editor = CKEDITOR.instances[p + '-content'];
            if (editor) {
                editor.destroy();
            }

            // Delete the surrounding div.
            var $div = $('#' + p);
            $div.remove();

            // Delete the tab navigation link.
            var $ul = $("#content-container ul.nav-tabs");
            var $a = $('a[href="#' + p + '"]', $ul);
            $a.closest('li').remove();
        }

        $(document).ready(function () {

            // Add autocompleter on the template field.
            $("#template").autocomplete("${createLink(controller: 'emailCampaign', action: 'autocompleteTemplate')}", {
                remoteDataType: 'json',
                preventDefaultReturn: true,
                selectFirst: true,
                useCache: false,
                filter: false,
                queryParamName: 'name',
                extraParams: {},
                onItemSelect: function(item) {
                    var parts = item.data[2];
                    if(parts) {
                        for(i = 0; i < parts.length; i++) {
                            addPart(parts[i], '', false);
                        }
                    }
                }
            });

            // Create CKEditor instance for each tab.
            $(".crm-editor-html").each(function(idx, elem) {
                createEditor(elem.getAttribute('id'));
            });

            // Manage "add new content part" modal.
            $("#crm-add-part form").submit(function(ev) {
                ev.preventDefault();
                var $name = $('input[name="name"]', $(this));
                addPart($name.val() || 'body', '', true);
                $name.val(''); // Clear the name field.
                $('#crm-add-part').modal('hide');
            });

            // Manage "rename content part" modal.
            $('#crm-rename-part').on('show', function () {
                var $form = $("form", $(this));
                var $oldName = $('input[name="currentName"]', $form);
                var $newName = $('input[name="name"]', $form);
                var currentName = $("#content-container ul.nav-tabs > li.active a").text();
                $oldName.val(currentName);
                $newName.val(currentName);
            });
            $("#crm-rename-part form").submit(function(ev) {
                ev.preventDefault();
                var $form = $(this);
                var $oldName = $('input[name="currentName"]', $form);
                var $newName = $('input[name="name"]', $form);
                var p = $oldName.val();
                var oldValue = $('textarea[name="' + p + '"]').val();
                deletePart($oldName.val());
                addPart($newName.val(), oldValue, true);
                $oldName.val('');
                $newName.val('');
                $('#crm-rename-part').modal('hide');
                $('a[href="#' + p + '"]', $ul).tab('show');
            });

            // Manage "delete content part" modal.
            $("#crm-delete-part form").submit(function(ev) {
                ev.preventDefault();
                var currentName = $("#content-container ul.nav-tabs > li.active a").text();
                deletePart(currentName);
                $('#crm-delete-part').modal('hide');
                $('#content-container ul.nav-tabs a:first').tab('show');
            });

            // When a modal is shows, make sure the first field get focus.
            $('.modal').on('shown', function () {
                $("input:visible:enabled:first", $(this)).focus();
            });

            /*$("#mainForm").submit(function(ev) {
                $(".crm-editor-html").each(function(idx, elem) {
                    createEditor(elem.getAttribute('id'));
                });
            });*/
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

            <div class="control-group">
                <label class="control-label">Avsändarens namn</label>

                <div class="controls">
                    <g:textField name="senderName" value="${cfg.senderName}" class="span11"/>
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

    </div>

    <div id="content-container" class="tabbable">
        <ul class="nav nav-tabs">
            <g:each in="${cfg.parts}" var="part" status="i">
                <li class="${i ? '' : 'active'}">
                    <a href="#${part}" data-toggle="tab">${part}</a>
                </li>
            </g:each>
            <li class="dropdown">
                <a href="#" class="dropdown-toggle" data-toggle="dropdown">Arkiv <b class="caret"></b></a>
                <ul class="dropdown-menu">
                    <li><a href="#crm-add-part" data-toggle="modal">Nytt innehåll...</a></li>
                    <li><a href="#crm-rename-part" data-toggle="modal">Döp om innehåll...</a></li>
                    <li><a href="#crm-delete-part" data-toggle="modal">Radera innehåll...</a></li>
                </ul>
            </li>
            <crm:pluginViews location="tabs" var="view">
                <crm:pluginTab id="${view.id}" label="${view.label}" count="${view.model?.totalCount}"/>
            </crm:pluginViews>
        </ul>

        <div class="tab-content">
            <g:each in="${cfg.parts}" var="part" status="i">
                <div class="tab-pane ${i ? '' : 'active'}" id="${part}">
                    <input type="hidden" name="parts" value="${part}"/>

                    <div class="row-fluid">
                        <g:textArea id="${part}-content" name="${part}" cols="70" rows="18"
                                    class="span11 crm-editor-html"
                                    value="${cfg[part]}"/>
                    </div>
                </div>
            </g:each>
        </div>

    </div>

    <div class="form-actions">
        <crm:button action="edit" visual="warning" icon="icon-ok icon-white" label="crmCampaign.button.save.label"/>
        <crm:button action="preview" visual="info" icon="icon-eye-open icon-white" label="emailCampaign.button.preview.label"/>
        <crm:button type="link" controller="crmCampaign" action="show" id="${crmCampaign.id}" icon="icon-remove"
                    label="crmCampaign.button.close.label"/>
    </div>

</g:form>

<div id="crm-add-part" class="modal hide fade">
    <g:form action="addPart" id="${crmCampaign.id}">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>

            <h3>Nytt innehåll</h3>
        </div>

        <div class="modal-body">

            <p>
                Om du använder en huvudmall uppbyggd av olika delar måste du skapa innehåll som fyller
                varje del i mallen. Du gör detta här genom att ange namnet på den del du vill lägga till.
                Namnet måste motsvara ett namn i mallen. Se mallens dokumentation för att ta reda på vad
                de olika delarna heter.
            </p>

            <div class="control-group">
                <label class="control-label">Innehållsnamn</label>

                <div class="controls">
                    <g:textField name="name" value="" class="input-medium"/>
                </div>
            </div>
        </div>

        <div class="modal-footer">
            <a href="#" class="btn" data-dismiss="modal">Avbryt</a>
            <button type="submit" class="btn btn-primary">Lägg till</button>
        </div>

    </g:form>
</div>

<div id="crm-rename-part" class="modal hide fade">
    <g:form action="renamePart" id="${crmCampaign.id}">

        <input type="hidden" name="currentName" value=""/>

        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>

            <h3>Döp om innehåll</h3>
        </div>

        <div class="modal-body">

            <p>
                Ange nytt namn på innehållet. Namnet måste motsvara ett namn i huvudmallen.
                Se mallens dokumentation för att ta reda på vad de olika delarna heter.
            </p>

            <div class="control-group">
                <label class="control-label">Nytt innehållsnamn</label>

                <div class="controls">
                    <g:textField name="name" value="" class="input-medium"/>
                </div>
            </div>
        </div>

        <div class="modal-footer">
            <a href="#" class="btn" data-dismiss="modal">Avbryt</a>
            <button type="submit" class="btn btn-primary">Döp om</button>
        </div>

    </g:form>
</div>

<div id="crm-delete-part" class="modal hide fade">
    <g:form action="deletePart" id="${crmCampaign.id}">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>

            <h3>Radera innehåll</h3>
        </div>

        <div class="modal-body">

            <p>
                Är du säker på att du vill radera innehållet <strong class="content-name"></strong>?
            </p>

        </div>

        <div class="modal-footer">
            <a href="#" class="btn" data-dismiss="modal">Avbryt</a>
            <button type="submit" class="btn btn-danger">Radera</button>
        </div>

    </g:form>
</div>

</body>
</html>
