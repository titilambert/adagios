###
Generated by coffee-script, any changes should be made to the adagios.coffee file
###
#
# Allow radio inputs as button in regular form
# http://dan.doezema.com/2012/03/twitter-bootstrap-radio-button-form-inputs/
#
# This stops regular posting for buttons and assigns values to a hidden input
# to enable buttons as a radio.
#

jQuery ($) ->
  $("div.btn-group[data-toggle=\"buttons-radio\"]").each ->
    group = $(this)
    form = group.parents("form").eq(0)
    name = group.attr("data-toggle-name")
    hidden = $("input[name=\"#{ name }\"]", form)
    $("button", group).each ->
      button = $(this)
      button.live "click", ->
        hidden.val $(this).val()

      button.addClass "active"  if button.val() is hidden.val()




$.extend $.fn.dataTableExt.oStdClasses,
  sSortAsc: "header headerSortDown"
  sSortDesc: "header headerSortUp"
  sSortable: "header"

(($) ->
  obIgnoreTables = [$("table#service-table")[0], $("table#contact-table")[0], $("table#host-table")[0], $("table#command-table")[0], $("table#timeperiod-table")[0]]
  filter_cache = {}
  object_types = ['service', 'servicegroup', 'host', 'hostgroup', 'contact', 'contactgroup', 'command', 'timeperiod']

  $.fn.dataTableExt.afnFiltering.push (oSettings, aData) ->
    # Disable filter for all tables except obIgnoreTables
    return true  if $.inArray(oSettings.nTable, obIgnoreTables) is -1

    # Default we show nothing
    object_type = oSettings["sTableId"].split("-")[0]
    cache_type = filter_cache[object_type]

    return true if cache_type is undefined

    # We are showing templates and this is register=0
    if aData[0] is "0" and cache_type is "2"
      return true

    if cache_type is "1" and aData[1] is "#{object_type}group" and aData[0] != "0"
      return true

    if cache_type is "0" and aData[1] is object_type and aData[0] != "0"
      return true

    # default no
    false

  $.fn.adagios_version = () ->
    $.get("http://adagios.opensource.is/rest/adagios/txt/version", (data) ->
      $(this).text data
      this
    ).error(->
      $(this).text "Unknown"
      this
    )
    this

  $.fn.ob_check_datatable_column_visibility = () ->
    # Hide columns when we are small
    window_width = $(window).width()
    $(this).each ->
      $this = $(this)
      # Don't hide the service name TODO this is semi helpfull on small devices, no hostname appears
      dt = $this.dataTable()
      columns = dt.fnSettings().aoColumns.length
      # 4 Visible columns
      console.log $this.attr('id')
      if $this.attr('id') == 'service-table'
        if window_width < 470
          dt.fnSetColumnVis 3, false
          dt.fnSetColumnVis 4, false
          dt.fnSetColumnVis 5, false
          dt.fnSetColumnVis 6, true
          return this
        else
          dt.fnSetColumnVis 3, true
          dt.fnSetColumnVis 6, false
      if columns > 5
        dt.fnSetColumnVis(5, (window_width > 970))
      if columns > 4
        dt.fnSetColumnVis(4, (window_width > 470))


    this
  #
  #     Creates a dataTable for adagios objects
  #
  #     aoColumns are used primarily for Titles
  #     example, aoColumns = [ { 'sTitle': 'Contact Name'}, { 'sTitle': 'Alias' } ]
  #
  #     
  $.fn.adagios_ob_configure_dataTable = (aoColumns, fetch) ->
    
    # Option column
    aoColumns.unshift
      sTitle: "register"
      bVisible: false
    ,
      sTitle: "object_type"
      bVisible: false
    ,
      sTitle: """<label rel="tooltip" title="Select All" id="selectall" class="checkbox"><input type="checkbox"></label>"""
      sWidth: "32px"

    $this = $(this)
    $this.data "fetch", fetch
    $this.data "aoColumns", aoColumns
    $this

  $.fn.adagios_ob_render_dataTable = ->
    $this = $(this)
    $this.dtData = []
    $this.fetch = $this.data("fetch")
    $this.aoColumns = $this.data("aoColumns")
    $this.jsonqueries = $this.fetch.length
    $.each $this.fetch, (f, v) ->
      object_type = v["object_type"]
      console.log """Populating #{ object_type } #{ $this.attr("id") }<br/>"""
      json_query_fields = ["id", "register"]
      $.each v["rows"], (k, field) ->
        json_query_fields.push field["cName"]  if "cName" of field
        json_query_fields.push field["cAltName"]  if "cAltName" of field
        json_query_fields.push field["cHidden"]  if "cHidden" of field

      $.getJSON("../rest/pynag/json/get_objects",
        object_type: object_type
        with_fields: json_query_fields.join(",")
      , (data) ->
        count = data.length
        $.each data, (i, item) ->
          field_array = [
            item["register"],
            object_type,
            """<input id="ob_mass_select" name="#{ item["id"] }" type="checkbox">"""
          ]
          $.each v["rows"], (k, field) ->
            cell = """<a href="id=#{ item["id"] }">"""
            field_value = ""
            cell += """<i class="#{ field.icon }"></i>"""  if "icon" of field
            if item[field["cName"]]
              field_value = item[field["cName"]]
            else
              field_value = item[field["cAltName"]]  if item[field["cAltName"]]
            field_value = field_value.replace("\"", "&quot;")
            field_value = field_value.replace(">", "&gt;")
            field_value = field_value.replace("<", "&lt;")
            if "truncate" of field and field_value.length > (field["truncate"] + 3)
              cell += """<abbr rel="tooltip" title=" #{ field_value }">#{ field_value.substr(0, field["truncate"]) } ...</abbr>"""
            else
              cell += " #{field_value}"
            cell += "</a>"
            field_array.push cell
            if field["cName"] is v["rows"][v["rows"].length - 1]["cName"]
              $this.dtData.push field_array
              count--
      ).success(->
        $this.jsonqueries = $this.jsonqueries - 1
        if $this.jsonqueries is 0
          $("[rel=tooltip]").tooltip()
          $this.data "dtData", $this.dtData
          $this.adagios_ob_dtPopulate()
      ).error (jqXHR) ->

      
      # TODO - fix this to a this style 
      
      #targetDataTable = $(this).data('datatable');
      #targetDataTable.parent().parent().parent().html('<div class="alert alert-error"><h3>ERROR</h3><br/>Failed to fetch data::<p>URL: ' + this.url + '<br/>Server Status: ' + jqXHR.status + ' ' + jqXHR.statusText + '</p></div>');
      this


  
  #
  #     Populates the datatable
  #
  #     jsonFields are used for describing which fields to fetch via json and how to handle them
  #     example, jsonFields = [ { 'cName': "command_name", 'icon_class': "glyph-computer-proces" }, ... ]
  #
  #     object_type is one of contact, command, host, service, timeperiod
  #     example, object_type = host
  #     
  $.fn.adagios_ob_dtPopulate = ->
    $this = $(this)
    object_type = $this.attr('id').split("-")[0]
    dtData = $this.data("dtData")
    aoColumns = $this.data("aoColumns")
    $("##{ object_type }-tab #loading").hide()
    console.log "Hiding ##{ object_type }-tab #loading"
    dt = $this.dataTable(
      aoColumns: aoColumns
      sPaginationType: "bootstrap"
      # "sScrollY":"260px",
      # "bAutoWidth":true,
      bAutoWidth:false
      bScrollCollapse: false
      bPaginate: true
      iDisplayLength: 100
      aaData: dtData
      sDom: "<'row-fluid'<'span7'<'toolbar_#{ object_type }'>>'<'span5'f>r>t<'row-fluid'<'span6'i><'span6'p>>"
      # Callback which assigns tooltips to visible pages
      fnDrawCallback: ->
        $("[rel=tooltip]").tooltip()
        $("input").click ->
          checked = $("input#ob_mass_select:checked").length
          $("#bulkselected").html checked
          if checked > 0
            $("#actions #modify").show()
          else
            $("#actions #modify").hide()
    )

    dt.ob_check_datatable_column_visibility()
    # Unbind sorting on the first visible column
    $("table\##{ object_type }-table th:first").unbind "click"

    $(".toolbar_#{ object_type }").html """
    <div class="row-fluid">
      <div class="span12"></div>
    </div>
    """
    if object_type != "command" and object_type != "timeperiod"
      $(".toolbar_#{ object_type } div.row-fluid div.span12").append """
          <div id="view_filter" class="btn-group pull-left"></div>"""

    $(".toolbar_#{ object_type } div.row-fluid div.span12").append """
        <div class="pull-left" id="actions">
          <div id="add" class="btn-group pull-left">
            <a href="#{BASE_URL}objectbrowser/add/#{object_type}" class="btn capitalize">
              Add #{object_type}
            </a>
            <a href="#" class="btn dropdown-toggle" data-toggle="dropdown">
              <i class="caret"></i>
            </a>
            <ul class="dropdown-menu nav">
              <li class="nav-header">Add</li>
            </ul>
          </div>
          <div id="modify" class="btn-group pull-right hide">
            <a rel="tooltip" id="copy" title="Copy" class="btn btn-important" data-target-bulk="bulk_copy" data-target="copy"><i class="icon-copy"></i></a>
            <a rel="tooltip" id="update" title="Edit" class="btn" data-target-bulk="bulk_edit" data-target="edit_object"><i class="glyph-pencil"></i></a>
            <a rel="tooltip" id="delete" title="Delete" class="btn" data-target-bulk="bulk_delete" data-target="delete_object"><i class="glyph-bin"></i></a>
          </div>
        </div>

        """
    $("#actions #modify a").on "click", (e) ->
      checked = $("input#ob_mass_select:checked").length
      if checked > 1
        params = {}
        swhat = $(this).attr('data-target-bulk')
        $form = $("form[name=\"bulk\"]")
        $form.attr "action", swhat
        $("table tbody input:checked").each (index) ->
          $("<input>").attr(
            type: "hidden"
            name: "change_" + $(this).attr("name")
            value: "1"
          ).appendTo $form

        $form.submit()
      else
        where = $(this).attr('data-target')
        id = $("table tbody input:checked").attr('name')
        window.location.href = window.location.href.split("#")[0] + "#{where}/id=#{id}"
      e.preventDefault()

    if (object_type != "command" and object_type != "timeperiod")
      $(".toolbar_#{ object_type } div.row-fluid ul.dropdown-menu").append """
      <li><a href="#{BASE_URL}objectbrowser/add/#{ object_type}group" class="capitalize">#{object_type}group</a></li>
      <li class="divider"></li>"""
      $(".toolbar_#{ object_type } div#view_filter.btn-group").append """
      <a rel="tooltip" title="Show #{ object_type }s" class="btn active" data-filter-type="0">
        <i class="glyph-computer-service"></i>
      </a>
      <a rel="tooltip" title="Show #{ object_type }groups" class="btn" data-filter-type="1">
        <i class="glyph-parents"></i>
      </a>
      <a rel="tooltip" title="Show #{ object_type } templates" class="btn" data-filter-type="2">
        <i class="glyph-cogwheels"></i>
      </a>"""

      filter_cache[object_type] = "0"

    for ot in object_types
      if ot is object_type or ot is "#{object_type}group"
        continue
      $(".toolbar_#{ object_type } div.row-fluid ul.dropdown-menu").append """
      <li class="capitalize"><a href="#{BASE_URL}objectbrowser/add/#{ ot }">#{ ot }</a></li>
      """

    console.log "Assignin click on #" + object_type + "-tab.tab-pane label#selectall"
    $("#" + object_type + "-tab.tab-pane label#selectall").on "click", () ->
      $checkbox = $("#" + object_type + "-tab.tab-pane #selectall input")
      console.log "#" + object_type + "-tab.tab-pane #selectall input"
      unless $checkbox.attr("checked") is `undefined`
        $(".tab-pane.active .dataTable input").each ->
          $(this).attr "checked", "checked"
      else
        $(".tab-pane.active .dataTable input").each ->
          $(this).removeAttr "checked"

      checked = $("input#ob_mass_select:checked").length
      $("#bulkselected").html checked
      if checked > 0
        $("#actions #modify").show()
      else
        $("#actions #modify").hide()

    # When inputs are selected in toolbar, we call redraw on the datatable which calls the filtering routing
    #        above 
    $("[class^=\"toolbar_\"] div#view_filter.btn-group a").on "click", (e) ->
      $target = $(this)
      e.preventDefault()
      return false  if $target.hasClass("active")
      object_type = $target.parentsUntil(".tab-content", ".tab-pane").attr("id").split("-")[0]
      $target.siblings().each ->
        $(this).removeClass "active"

      $target.addClass "active"
      filter_cache[object_type] = $target.attr('data-filter-type')
      $("table#" + object_type + "-table").dataTable().fnDraw()
      false

    $("div\##{object_type}_filter.dataTables_filter input").addClass "input-medium search-query"

    if object_type == "service"
      dt.fnSort [[3, "asc"], [4, "asc"]]
    else
      dt.fnSort [[3, "asc"]]

  
  #return this.each(function() {
  
  #
  #     Object Browser, This runs whenever "Run Check Plugin" is clicked
  #
  #     It resets the color of the OK/WARNING/CRITICAL/UNKNOWN button
  #     Runs a REST call to run the check_command and fetch the results
  #
  #     Calling button/href needs to have data-object-id="12312abc...."
  #     
  $.fn.adagios_ob_run_check_command = ->
    
    # Fetch the calling object
    modal = $(this)
    
    # Get the object_id
    id = modal.attr("data-object-id")
    object_type = modal.attr("data-object-type")
    unless id
      alert "Error, no data-object-id for run command"
      return false
    
    # Reset the class on the button
    $("#run_check_plugin #state").removeClass "label-important"
    $("#run_check_plugin #state").removeClass "label-warning"
    $("#run_check_plugin #state").removeClass "label-success"
    $("#run_check_plugin #state").html "Pending"
    $("#run_check_plugin #output pre").html "Executing check plugin"
    plugin_execution_time = $("#run_check_plugin div.progress").attr("data-timer")
    if plugin_execution_time > 1
      updateTimer = ->
        step += 1
        $("#run_check_plugin div.bar").css "width", step * 5 + "%"
        setTimeout updateTimer, step * steps  if step < 20
      $("#run_check_plugin div.progress").show()
      bar = $("#run_check_plugin div.bar")
      step = 0
      steps = (plugin_execution_time / 20) * 100
      updateTimer()
    
    # Run the command and fetch the output JSON via REST
    
    # Default to unknown if data[0] is less than 3
    
    # Set the correct class for state coloring box
    
    # Fill it up with the correct status
    
    # Put the plugin output in the correct div
    
    # Show the refresh button
    
    # Assign this command to the newly shown refresh button
    $.getJSON(BASE_URL + "rest/pynag/json/run_check_command",
      object_id: id
    , (data) ->
      statusLabel = "label-inverse"
      statusString = "Unknown"
      if object_type is "host"
        if data[0] > 1
          statusLabel = "label-important"
          statusString = "DOWN"
        else
          statusLabel = "label-success"
          statusString = "UP"
      else
        if data[0] is 2
          statusLabel = "label-important"
          statusString = "Critical"
        if data[0] is 1
          statusLabel = "label-warning"
          statusString = "Warning"
        if data[0] is 0
          statusLabel = "label-success"
          statusString = "OK"
      $("#run_check_plugin #state").addClass statusLabel
      $("#run_check_plugin #state").html statusString
      if data[1]
        $("#run_check_plugin div#output pre").text data[1]
      else
        $("#run_check_plugin #output pre").html "No data received on stdout"
      if data[2]
        $("#run_check_plugin #error pre").text data[2]
        $("#run_check_plugin div#error").show()
      $("#run_check_plugin_refresh").show()
      $("#run_check_plugin div.progress").hide()
      $("#run_check_plugin_refresh").click ->
        $(this).adagios_ob_run_check_command()

    ).error (jqXHR) ->
      
      # TODO - fix this to a this style 
      alert "Failed to fetch data: URL: \"" + @url + "\" Server Status: \"" + jqXHR.status + "\" Status: \"" + jqXHR.statusText + "\""

    
    # Stop the button from POST'ing
    this
) jQuery
$(document).ready ->
  $("[rel=tooltip]").popover()
  $("#popover").popover()
  $("select").chosen()

  $('div.modal#notifications div.alert').bind 'close', (e) ->
    $this = $(this)
    id = $this.attr 'data-notification-dismiss'
    console.log "dismissing id #{id}"
    if $this.data 'dismissed'
      return true
    if id
      $.post "#{BASE_URL}rest/adagios/txt/clear_notification", { notification_id: id }
      ,(data) ->
        num_notifications = 0
        if data == "success"
          $('span#num_notifications').each ->
            num = +$(this).text()
            num_notifications = num - 1
            $(this).text num_notifications
          console.log "Notifications #{num_notifications}"
          if num_notifications == 0
            $('a[href="#notifications"] div.badge').removeClass 'badge-warning'
            $('div#notifications.modal div.modal-body').text "No notifications"
          $this.data 'dismissed', 1
          $this.alert 'close'
        else
          alert "Unable to dismiss notification for #{id}"
          console.log "Unable to do stuff for #{id}"
      return e.preventDefault()
    true