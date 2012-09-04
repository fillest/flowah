<%inherit file="/base.mako" />


<script type="text/coffeescript">
	$ ->
		$('body').on 'click', '.js', (event) ->
			event.preventDefault()

		$('.js-confirm').click (event) ->
			if not confirm "are you sure?"
				event.stopImmediatePropagation()
				return false

		$('.js-delete-entry').click ->  #note: must be executed later than $('.js-confirm').click ..
			$.post("${request.route_path('entry.delete')}", {
				entry_id: $(this).closest('li').data('entry-id'),
			}, -> window.location.reload()).error -> alert 'fail'

		$('.js-cross-entry').click ->
			$.post("${request.route_path('entry.cross')}", {
				entry_id: $(this).closest('li').data('entry-id'),
			}, -> window.location.reload()).error -> alert 'fail'

		render_entry_form = (entry_id, content, priority, parent_id = '') ->
			'
			<textarea rows="1" style="width: 300px;">' + content + '</textarea>

			<input class="js-entry-form-parent-id" type="hidden" value="' + parent_id + '"></input>

			<br />
			<i class="icon-exclamation-sign"></i>
			<select class="js-entry-priority">
				% for value, params in sorted(priorities.items(), reverse = True):
					<option value="${value}" ' + (if priority == ${value} then 'selected="selected"' else '')  + '>${params['title']}</option>
				% endfor
			</select>

			<br />
			<button class="js-save-entry btn-mini"
				data-entry-id="' + entry_id + '"
				data-entry-priority="' + priority + '">save</button>
			'

		$('.js-edit-entry').click ->
			el = $(this)
			parent = el.closest('li')

			el.hide()
			parent.find('.js-content-rendered').hide()

			content = parent.find('.js-content-source').html()
			parent_id = parent.closest('.js-entries').closest('li').data('entry-id') or ''
			$('
				<span>' + render_entry_form(el.data('entry-id'), content, el.data('entry-priority'), parent_id) + '</span>
			').appendTo(parent).focus()

		$('body').on 'click', '.js-save-entry', ->
			el = $(this)
			parent = el.parent()

			$.post('${request.route_path('entry.save')}', {
				entry_id: el.data('entry-id'),
				content: parent.find('textarea').val(),
				priority: parent.find('.js-entry-priority').val(),
				parent_id: parent.find('.js-entry-form-parent-id').val(),
			}, -> window.location.reload()).error -> alert 'fail'

		$('.js-create-entry-bottom').click ->
			$('
				<li>' + render_entry_form('new', "", 0) + '</li>
			').appendTo($ 'body .js-entries:first').find('textarea').focus()

		$('.js-create-entry-top').click ->
			$('
				<li>' + render_entry_form('new', "", 0) + '</li>
			').prependTo($ 'body .js-entries:first').find('textarea').focus()

		$('.js-add-child').click ->
			parent = $(this).closest('li')
			id = parent.data('entry-id')
			$('
				<li>' + render_entry_form('new', "", 0, id) + '</li>
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
		    	$.get('${request.route_path('entry.move')}?id=' + ui.draggable.data('entry-id') + '&parent_id=' + $(this).data('entry-id'), ->
		    		window.location.reload()
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
		    	$.get('${request.route_path('entry.move')}?id=' + ui.draggable.data('entry-id') + '&parent_id=', ->
		    		window.location.reload()
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
</style>

<form action="${request.route_path('root')}" method="get">
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
				data-entry-priority="${entry.priority}"><i class="icon-pencil"></i></a>
			<a href="#" class="js-add-child js"><i class="icon-plus"></i></a>
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
			</div>
		</div>
		<div class="js-entry-boundary" style="clear: both;"></div>

		% if entry.children:
			<ul class="unstyled js-entries">
				% for ch in entry.children:
					% for l in range(level):
						<div style="display: block; width: 2em; float: left;">&nbsp;</div>
					%endfor
					${render_entry(ch, level + 1)}
				% endfor
			</ul>
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
