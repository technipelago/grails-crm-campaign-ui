<table class="table table-striped">
    <thead>
    <th><g:message code="crmContent.filename.label" default="Name"/></th>
    <th><g:message code="crmContent.modified.label" default="Modified"/></th>
    <th><g:message code="crmContent.length.label" default="Size"/></th>
    </thead>
    <tbody>
    <g:each in="${list}" var="res" status="i">
        <g:set var="metadata" value="${res.metadata}"/>
        <tr class="status-${res.statusText} ${(i + 1) == params.int('selected') ? 'active' : ''}">
            <td>
                <img src="${crm.fileIcon(contentType: metadata.contentType)}" alt="${metadata.contentType}"
                     title="${metadata.contentType}"/>
                <g:link controller="crmContent" action="edit"
                        params="${[id: res.id, referer: request.forwardURI + '#' + view.id]}">
                    ${res.encodeAsHTML()}
                </g:link>
            </td>
            <td><g:formatDate date="${metadata.modified ?: metadata.created}" type="datetime"/></td>
            <td>${metadata.size}</td>
        </tr>
    </g:each>
    </tbody>
</table>

<crm:hasPermission permission="${controllerName + ':edit'}">
    <g:uploadForm controller="crmContent" action="attachDocument">
        <g:hiddenField name="ref" value="${reference}"/>
        <g:hiddenField name="referer" value="${request.forwardURI + '#' + view.id}"/>
        <g:hiddenField name="status" value="shared"/>
        <div class="form-actions btn-toolbar">
            <crm:button type="link" group="true" controller="crmContent" action="create"
                        params="${[ref: reference, referer: request.forwardURI + '#' + view.id, contentType: 'text/html']}"
                        visual="success" icon="icon-file icon-white" label="crmContent.button.create.label">
                <button class="btn btn-success dropdown-toggle" data-toggle="dropdown">
                    <span class="caret"></span>
                </button>
                <ul class="dropdown-menu">
                    <li>
                        <g:link controller="crmContent" action="create"
                                params="${[ref: reference, referer: request.forwardURI + '#' + view.id, contentType: 'text/html']}">
                            HTML
                        </g:link>
                    </li>
                    <li>
                        <g:link controller="crmContent" action="create"
                                params="${[ref: reference, referer: request.forwardURI + '#' + view.id, contentType: 'text/plain']}">
                            TEXT
                        </g:link>
                    </li>
                </ul>
            </crm:button>
            <crm:button action="attachDocument" visual="primary" icon="icon-upload icon-white"
                        label="crmContent.button.upload.label"/>
            <input type="file" name="file" style="margin-left:10px;"/>
        </div>
    </g:uploadForm>
</crm:hasPermission>