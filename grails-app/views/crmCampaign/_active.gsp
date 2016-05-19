<r:script>
    var CrmActiveCampaigns = {
        flash: function($elem) {
            $elem.removeClass('btn-success');
            $elem.find('i').removeClass('icon-white');
            setTimeout(function() {
                $elem.addClass('btn-success');
                $elem.find('i').addClass('icon-white');
            }, 750);
        }
    };
    $(document).ready(function () {
        $('#active-campaigns .crm-campaign').hover(function(ev) {
            $(this).children().toggle();
        }, function(ev) {
            $(this).children().toggle();
        });
        $('#active-campaigns .crm-pick').click(function(ev) {
            ev.preventDefault();
            var $self = $(this);
            var id = $self.data('crm-id');
            var ref = $self.data('crm-ref');
            CrmActiveCampaigns.flash($self);
            $.post("${createLink(controller: 'crmCampaign', action: 'addRecipient')}", {'id': id, 'ref': ref}, function(campaign) {
                var $div = $self.parent().siblings().first();
                if(campaign.included) {
                    $div.addClass('active');
                } else {
                    $div.removeClass('active');
                }
                $div.html(campaign.name + '&nbsp;(' + campaign.recipients + ')');
            });
        });
    });
</r:script>

<div id="active-campaigns" class="well sidebar-nav">
    <ul class="nav nav-list">
        <li class="nav-header">
            <i class="icon-bullhorn"></i>
            <g:message code="crmCampaign.active.title" default="Active campaigns"/>
        </li>
        <g:each in="${list}" var="c">
            <li class="crm-campaign">
                <div class="${c.contains(bean.email, bean.telephone ?: bean.mobile) ? 'active' : ''}">
                    ${c.name}&nbsp;(${c.recipients})
                </div>

                <div class="hide">
                    <button type="button" class="btn btn-mini btn-success crm-pick" data-crm-id="${c.id}"
                            data-crm-ref="${reference}">
                        <i class="icon-circle-arrow-right icon-white"></i>
                        Add
                    </button>
                    <crm:referenceLink reference="${c}" class="pull-right">
                        View&hellip;
                    </crm:referenceLink>
                </div>
            </li>
        </g:each>
    </ul>
</div>