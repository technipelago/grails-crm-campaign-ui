<r:script>
    var searchDelay = (function(){
      var timer = 0;
      return function(callback, ms){
        clearTimeout (timer);
        timer = setTimeout(callback, ms);
      };
    })();
    var CRM = {
        sort: '${recipientSort}',
        order: 'asc',
        offset: 0,
        max: 10,
        load: function() {
            var params = {};
            params.q = $('#recipient-container .crm-search input').val();
            params.sort = CRM.sort;
            params.order = CRM.order;
            params.offset = CRM.offset;
            params.max = CRM.max;
            $('#recipient-container tbody').load("${createLink(action: 'recipients', id: bean.id)}", $.param(params), function() {
                var $firstRow = $('#recipient-container tbody .crm-recipient').first();
                if($firstRow) {

                    CRM.bindListEvents();

                    var totalCount = $firstRow.data('crm-total');
                    if(!totalCount || (totalCount <= CRM.max)) {
                        $('#pagination').empty();
                        return; // No records found, nothing to paginate.
                    }
                    var offset = $firstRow.data('crm-offset');
                    var max = $firstRow.data('crm-max');
                    var pages = Math.ceil(totalCount / max);
                    var $ul = $('<ul/>');

                    // Prev button.
                    var $li = $('<li><a href="#">&laquo;</a></li>');
                    if(offset <= 0) {
                        $li.addClass('disabled');
                    } else {
                        $('a', $li).click(function(ev) {
                            ev.preventDefault();
                            $(this).html($('#spinner').clone());
                            CRM.offset = CRM.offset - CRM.max;
                            CRM.load();
                        });
                    }
                    $ul.append($li);

                    for(page = 0; page < pages; page++) {
                        var $a = $('<a href="#"/>');
                        $a.text(page + 1);
                        $a.data('crm-offset', page * CRM.max);
                        $li = $('<li/>');
                        $li.append($a);
                        $a.click(function(ev) {
                            ev.preventDefault();
                            $(this).html($('#spinner').clone());
                            CRM.offset = $(this).data('crm-offset');
                            CRM.load();
                        });
                        if((page * CRM.max) == CRM.offset) {
                            $li.addClass('active');
                        }
                        $ul.append($li);
                    }

                    // Next button.
                    $li = $('<li><a href="#">&raquo;</a></li>');
                    if(offset >= ((pages - 1) * CRM.max)) {
                        $li.addClass('disabled');
                    } else {
                        $('a', $li).click(function(ev) {
                            ev.preventDefault();
                            $(this).html($('#spinner').clone());
                            CRM.offset = CRM.offset + CRM.max;
                            CRM.load();
                        });
                    }
                    $ul.append($li);

                    $('#pagination').html($ul);
                }
            });
        },

        bindListEvents: function() {
            $('#recipient-container tbody .crm-info').click(function (ev) {
                ev.preventDefault();
                // Load modal form with result.
                $("#recipient-modal .modal-body").load($(this).attr('href'), function () {
                    $("#recipient-modal").modal('show');
                });
                return false;
            });
        }

    };

    $(document).ready(function () {

        $('#changeAll').click(function (event) {
            $(":checkbox[name='recipients']", $(this).closest('form')).prop('checked', $(this).is(':checked'));
        });

        $('#recipient-container .crm-search').click(function(ev) {
            var $self = $(this);
            $self.find('label').hide();
            $self.find('input').removeClass('hide');
            $self.find('input').focus();
        });

        $('#recipient-container .crm-search input').keyup(function() {
            searchDelay(function(){
                CRM.offset = 0;
                CRM.load();
            }, 750 );
        });

        $('#recipient-container .crm-search input').keydown(function(event){
            if(event.keyCode == 13) {
                event.preventDefault();
                return false;
            }
        });

        $('#recipient-container .crm-sort').click(function(ev) {
            var $self = $(this);
            var sort = $self.data('crm-sort');
            if(sort == CRM.sort) {
                if(CRM.order == 'asc') {
                    CRM.order = 'desc';
                } else {
                    CRM.order = 'asc';
                }
            } else {
                CRM.order = 'asc';
            }
            CRM.sort = sort;
            CRM.load();
        });

        $('#add-recipient-modal').on('shown', function(ev) {
            $('input[name="email"]', this).focus();
        });

        CRM.load();
    });
</r:script>

<div id="recipient-container">
    <g:form action="deleteRecipient">

        <g:hiddenField name="id" value="${bean.id}"/>

        <table class="table table-striped">
            <thead>
            <tr>
                <th class="crm-search">
                    <label>
                        <g:message code="crmCampaignRecipient.name.label" default="Name"/>
                        <i class="icon-search"></i>
                    </label>
                    <input type="text" name="q" maxlength="80" class="hide"/>
                </th>
                <th>
                    <a href="javascript:void(0);" class="crm-sort" data-crm-id="${bean.id}"
                       data-crm-sort="dateSent" data-crm-order="asc">
                        <g:message code="crmCampaignRecipient.dateSent.label"/>
                    </a>
                </th>
                <th>
                    <a href="javascript:void(0);" class="crm-sort" data-crm-id="${bean.id}"
                       data-crm-sort="dateOpened" data-crm-order="asc">
                        <g:message code="crmCampaignRecipient.dateOpened.label"/>
                    </a>
                </th>
                <th>
                    <a href="javascript:void(0);" class="crm-sort" data-crm-id="${bean.id}"
                       data-crm-sort="reason" data-crm-order="asc">
                        <g:message code="crmCampaignRecipient.status.label"/>
                    </a>
                </th>
                <th><g:checkBox name="changeAll"
                                title="${message(code: 'crmCampaignRecipient.button.select.all.label', default: 'Select all')}"/></th>
            </tr>
            </thead>
            <tbody>
            <tr>
                <td colspan="6">
                    <g:img dir="images" file="spinner.gif" alt="Loading..."/>
                </td>
            </tr>
            </tbody>
        </table>

        <div id="pagination" class="pagination${count > 500 ? ' pagination-mini' : ''}"></div>

        <div class="form-actions">

            <a href="#add-recipient-modal" class="btn btn-success" data-toggle="modal">

                <i class="icon-plus icon-white"></i>
                <g:message code="crmCampaignRecipient.button.add.label" default="Add"/>
            </a>

            <crm:button label="crmCampaignRecipient.button.delete.label"
                        title="crmCampaignRecipient.button.delete.help"
                        icon="icon-trash icon-white"
                        visual="danger"
                        confirm="crmCampaignRecipient.button.delete.confirm.message"
                        permission="crmCampaign:edit"/>

        </div>
    </g:form>
</div>

<div id="recipient-modal" class="modal hide fade">
    <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>

        <h3>
            <g:message code="crmCampaign.recipients.title" args="[entityName, bean]"/>
        </h3>
    </div>

    <div class="modal-body">
        <p></p>
    </div>

    <div class="modal-footer">
        <a href="#" class="btn" data-dismiss="modal">
            <i class="icon-remove"></i>
            <g:message code="crmCampaignRecipient.button.close.label" default="Close"/>
        </a>
    </div>
</div>

<div id="add-recipient-modal" class="modal hide fade">
    <g:form action="recipients">
        <input type="hidden" name="id" value="${bean.id}"/>

        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>

            <h3>
                <g:message code="crmCampaignRecipient.add.title" args="[entityName, bean]"/>
            </h3>
        </div>

        <div class="modal-body">
            <div class="control-group">
                <label class="control-label">
                    <g:message code="crmCampaignRecipient.email.label" default="Email"/>
                </label>

                <div class="controls">
                    <g:textField name="email" class="span11"/>
                </div>
            </div>
            <div class="control-group">
                <label class="control-label">
                    <g:message code="crmCampaignRecipient.telephone.label" default="Phone"/>
                </label>

                <div class="controls">
                    <g:textField name="telephone" class="span6"/>
                </div>
            </div>
            <div class="control-group">
                <label class="control-label">
                    <g:message code="crmCampaignRecipient.name.label" default="Name"/>
                </label>

                <div class="controls">
                    <g:textField name="name" class="span11"/>
                </div>
            </div>
        </div>

        <div class="modal-footer">
            <button type="submit" class="btn btn-success">
                <i class="icon-ok icon-white"></i>
                <g:message code="crmCampaignRecipient.button.add.label" default="Add"/>
            </button>
            <a href="#" class="btn" data-dismiss="modal">
                <i class="icon-remove"></i>
                <g:message code="crmCampaignRecipient.button.close.label" default="Close"/>
            </a>
        </div>
    </g:form>
</div>

<div class="hidden">
    <g:img dir="images" file="spinner.gif" alt="Loading..." id="spinner"/>
</div>