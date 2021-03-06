<%inherit file="/base.mako" />


<%block name="title">${request.GET.get('tags') or 'all'}</%block>


<script type="text/javascript">
	var t = setInterval(function () {
		if ($.cookie('set_scroll_pos')) {
			$(window).scrollTop($.cookie('set_scroll_pos'));
		}
	}, 10);
	$(function () {
		clearInterval(t);
		$.removeCookie('set_scroll_pos');
	});
</script>

<script type="text/coffeescript">
	$ ->
		reload_page = ->
			# avoid reload() that causes excess static ifmodified requests
			$.cookie 'set_scroll_pos', $(window).scrollTop()
			window.location.href = '${request.url}'

		show_spinners = ->
			$('body').css 'cursor', 'wait'
			$('#spinner').show()


		$('body').on 'click', '.js', (event) ->
			event.preventDefault()

		$('.js-confirm').click (event) ->
			if not confirm "are you sure?"
				event.stopImmediatePropagation()
				return false

		$('.js-delete-entry').click ->  #note: must be executed later than $('.js-confirm').click ..
			show_spinners()
			$.post("${request.route_path('entry.delete')}", {
				entry_id: $(this).closest('li').data('entry-id'),
			}, -> reload_page()).error -> alert 'fail'

		$('.js-cross-entry').click ->
			$('#spinner').show()
			$.post("${request.route_path('entry.cross')}", {
				entry_id: $(this).closest('li').data('entry-id'),
			}, -> reload_page()).error -> alert 'fail'

		$('.js-fold-entry').click ->
			show_spinners()
			$.post("${request.route_path('entry.fold')}", {
				entry_id: $(this).closest('li').data('entry-id'),
			}, -> reload_page()).error -> alert 'fail'
			
		render_entry_form = (entry_id, content, priority, tags, parent_id = '') ->
			'
			<i class="icon-edit"></i>
			<textarea class="js-entry-form-content" rows="1" style="width: 300px;">' + content + '</textarea>

			<input class="js-entry-form-parent-id" type="hidden" value="' + parent_id + '" />

			<br />
			<i class="icon-exclamation-sign"></i>
			<select class="js-entry-priority">
				% for value, params in sorted(priorities.items(), reverse = True):
					<option value="${value}" ' + (if priority == ${value} then 'selected="selected"' else '')  + '>${params['title']}</option>
				% endfor
			</select>

			<br />
			<i class="icon-tags"></i>
			<input class="js-entry-form-tags" type="text" value="' + tags + '" />

			<br />
			<button class="js-save-entry btn-mini"
				data-entry-id="' + entry_id + '"
				data-entry-priority="' + priority + '"
				data-tags="' + tags + '"
				>save</button>
			'

		$('.js-edit-entry').click ->
			el = $(this)
			parent = el.closest('li')

			el.hide()
			parent.find('.js-content-rendered').hide()

			content = parent.find('.js-content-source').html()
			parent_id = parent.closest('.js-entries').closest('li').data('entry-id') or ''
			$('
				<span>' + render_entry_form(el.data('entry-id'), content, el.data('entry-priority'), el.data('tags'), parent_id) + '</span>
			').appendTo(parent).focus()

			$('.js-entry-form-tags').bind 'keydown', 'ctrl+return', -> $('.js-save-entry').click()
			$('.js-entry-form-content').bind 'keydown', 'ctrl+return', -> $('.js-save-entry').click()

		$('body').on 'click', '.js-save-entry', ->
			show_spinners()

			el = $(this)
			parent = el.parent()

			$.post('${request.route_path('entry.save')}', {
				entry_id: el.data('entry-id'),
				content: parent.find('textarea').val(),
				priority: parent.find('.js-entry-priority').val(),
				parent_id: parent.find('.js-entry-form-parent-id').val(),
				tags: parent.find('.js-entry-form-tags').val(),
			}, -> reload_page()).error -> alert 'fail'

		$('.js-create-entry-bottom').click ->
			$('
				<li>' + render_entry_form('new', "", 0, "") + '</li>
			').appendTo($ 'body .js-entries:first').find('textarea').focus()

		$('.js-create-entry-top').click ->
			$('
				<li>' + render_entry_form('new', "", 0, "") + '</li>
			').prependTo($ 'body .js-entries:first').find('textarea').focus()

		$('.js-add-child').click ->
			parent = $(this).closest('li')
			id = parent.data('entry-id')
			$('
				<li>' + render_entry_form('new', "", 0, "", id) + '</li>
			').insertAfter(parent.find('.js-entry-boundary:first')).find('textarea').focus()

		$('.js-expand-content').click ->
			$(this).closest('li').find('.js-content-rendered-full').show()
			$(this).hide()
		$('.js-content-rendered-full').click ->
			$(this).closest('li').find('.js-expand-content').show()
			$(this).hide()


		$('.js-entries li').draggable({
		    #handle: ' > dl',
		    opacity: 0.8,
		    addClasses: false,
		    helper: 'clone',
		    zIndex: 100,
		    delay: 300,
		})

		$('.js-entries li').droppable({
		    greedy: true,
		    #accept: '#entries li',
		    addClasses: false,
		    tolerance: 'pointer',
		    drop: (e, ui) ->
		    	show_spinners()
		    	$.get('${request.route_path('entry.move')}?id=' +
		    			ui.draggable.data('entry-id') + '&parent_id=' + $(this).data('entry-id'), ->
		    		reload_page()
		    	).error -> alert 'fail'
		    	$(this).css "border", ''
		    over: ->
		    	$(this).css "border", '1px solid #000'
		    out: ->
		    	$(this).css "border", ''
		})
		$('#js-root-parent').droppable({
		    #accept: '#entries li',
		    addClasses: false,
		    tolerance: 'pointer',
		    drop: (e, ui) ->
		    	show_spinners()
		    	$.get('${request.route_path('entry.move')}?id=' + ui.draggable.data('entry-id') + '&parent_id=', ->
		    		reload_page()
		    	).error -> alert 'fail'
		    	$(this).css "background-color", ''
		    over: ->
		    	$(this).css "background-color", '#ccc'
		    out: ->
		    	$(this).css "background-color", ''
		})
</script>

<style type="text/css">
	.js-entries > li > .buttons {visibility: hidden; float: left;}
	.js-entries > li:hover > .buttons {visibility: visible;}
	.content-rendered {text-overflow: '(…)'; width: 800px; white-space: nowrap; overflow: hidden;}
	#spinner {position: fixed; top: 0; left: 0; z-index: 9000;}
	.rendered-tags {opacity: 0.2; margin-left: 0.7em;}
	.rendered-tags:hover {opacity: 1;}
</style>

<img id="spinner" class="hide" src="http://cdn.fillest.ru/spinner.gif" alt="loading..." title="loading..." />

<form action="${request.route_path('root')}" method="get">
	<i class="icon-tags"></i> <input name="tags" type="text" value="${request.GET.get('tags', '')}" />

	% for value, params in sorted(priorities.items(), reverse = True):
		<label class="checkbox inline">
			<input name="pr" type="checkbox" value="${value}" autocomplete="off"
				${'checked="checked"' if unicode(value) in request.GET.getall('pr') else ''} />
			${params['title']}
		</label>
		##<option value="${value}" ' + (if priority == ${value} then 'selected="selected"' else '')  + '>${params['title']}</option>
	% endfor

	<button type="submit" class="btn btn-small">filter</button>
</form>

<%def name="render_entry (entry, level = 1)">
    <li data-entry-id="${entry.id}">
		<div class="buttons">
			<a href="#" class="js js-cross-entry"><i class="icon-check"></i></a>
			<a href="#" class="js-confirm js-delete-entry js"><i class="icon-remove"></i></a>
			<a href="#" class="js-edit-entry js"
				data-entry-id="${entry.id}"
				data-entry-priority="${entry.priority}"
				data-tags="${entry.tags_to_string()}"
				><i class="icon-pencil"></i></a>
			<a href="#" class="js-add-child js"><i class="icon-plus"></i></a>
			<a href="#" class="js-fold-entry js" ${'style="visibility: visible"' if entry.is_folded else '' |n}>
				<i class="icon-folder-${'open' if entry.is_folded else 'close'}"
					${'style="visibility: hidden"' if not entry.children else '' |n}></i>
			</a>
		</div>
		<div style="float: left; margin-left: 0.3em;">
			<span class="js-content-source" style="display: none;">${entry.content}</span>

			<div class="content-rendered js-content-rendered">
				•
				<span style="background: ${priorities[entry.priority]['color']}; ${'visibility: hidden;' if not entry.priority else ''}">
					<i class="icon-exclamation-sign icon-white"></i></span>
				<span class="js-expand-content"
					style="cursor: crosshair; ${'text-decoration: line-through;' if entry.is_crossed else ''}">${entry.render()}</span>
				<span class="js-content-rendered-full" style="display: none; cursor: n-resize">${entry.render(full = True)}</span>

				% if entry.tags_to_string():
					<span class="rendered-tags">
						<i class="icon-tags"></i> ${entry.tags_to_string()}
					</span>
				% endif
			</div>
		</div>
		<div class="js-entry-boundary" style="clear: both;"></div>

		% if entry.children:
			% if not entry.is_folded:
				<ul class="unstyled js-entries">
					% for ch in entry.children:
						% for l in range(level):
							<div style="display: block; width: 2em; float: left;">&nbsp;</div>
						%endfor
						${render_entry(ch, level + 1)}
					% endfor
				</ul>
			% endif
		% endif
	</li>
</%def>


<div>
	<a href="#" class="js-create-entry-top js"><i class="icon-plus"></i></a>
</div>

<div id="js-root-parent" style="height: 0.5em;"></div>
<ul class="unstyled js-entries">
	% for entry in entries:
		${render_entry(entry)}
	% endfor
</ul>

<div>
	<a href="#" class="js-create-entry-bottom js"><i class="icon-plus"></i></a>
</div>