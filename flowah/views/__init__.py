#coding: utf-8
from pyramid.httpexceptions import HTTPFound, HTTPForbidden
from pyramid.view import view_config
from flowah.data.models import Entry
from sapyens.helpers import raise_not_found, get_by_id, add_route
from ordereddict import OrderedDict  #py2.6
import re


RE_TAG = re.compile(r'(\w+)', re.UNICODE)
RE_TAG_Q = re.compile(r'(\w+)|([()])', re.UNICODE)


priorities = {
	0: {'title': u'not set', 'color': '#fff'},
	6: {'title': u'later', 'color': '#eee'},
	7: {'title': u'soon', 'color': '#be8'},
	8: {'title': u'week', 'color': '#fd7'},
	9: {'title': u'today', 'color': '#e99'},
	10: {'title': u'now', 'color': '#d00'},
}

@add_route('root', '/')
@view_config(route_name = 'root', renderer = '/list.mako', permission = 'admin')
def list_ (request):
	priority = map(int, request.GET.getall('pr'))

	tags = request.GET.get('tags', '')
	def repl (matchobj):
		m = matchobj.group(0)
		if m in ('or', 'and', 'not', '(', ')'):
			return m.upper()
		else:
			return u"tags LIKE '%%#%s#%%'" % m
	tags = re.sub(RE_TAG_Q, repl, tags)

	entries = OrderedDict()
	q = Entry.query.order_by(Entry.priority.desc(), Entry.created_time.desc())
	if tags:
		q = q.filter(tags)
	if priority:
		q = q.filter(Entry.priority.in_(priority))
	for e in q:
		e.children = []
		entries[e.id] = e

	keys_to_del = []
	items = entries.items()
	for id, e in items:
		if e.parent_id:
			keys_to_del.append(id)
			if e.parent_id not in entries: #for filter
				entries[e.parent_id] = e.parent
				e.parent.children = []
				items.append((e.parent_id, e.parent)) #visit parents too later so hierarchy doesnt breake
			entries[e.parent_id].children.append(e)
	for id in keys_to_del:
		del entries[id]

	return {
		'entries': entries.values(),
		'priorities': priorities,
	}

@add_route('entry.save', '/save')
@view_config(route_name = 'entry.save', renderer = 'string', permission = 'admin')
def save (request):
	tags = u' '.join(u'#%s#' % tag for tag in sorted(set(RE_TAG.findall(request.POST['tags']))))

	if request.POST['entry_id'] == 'new':
		entry = Entry(
			content = request.POST['content'],
			tags = tags,
			priority = request.POST['priority'],
			parent_id = request.POST['parent_id'] or None,
		).add()
	else:
		assert request.POST['entry_id'] != request.POST['parent_id']
		entry = Entry.try_get(id = request.POST['entry_id']).set(
			content = request.POST['content'],
			tags = tags,
			priority = request.POST['priority'],
			parent_id = request.POST['parent_id'] or None,
		).add()

	return 'ok'

@add_route('entry.delete', '/delete')
@view_config(route_name = 'entry.delete', permission = 'admin', renderer = 'string')
def delete (request):
	Entry.query.filter_by(id = request.POST['entry_id']).delete()
	return 'ok'

@add_route('entry.move', '/move')
@view_config(route_name = 'entry.move', renderer = 'string', permission = 'admin')
def move (request):
	assert request.GET['id'] != request.GET['parent_id']
	Entry.query.filter_by(id = request.GET['id']).update({"parent_id": request.GET['parent_id'] or None}, synchronize_session=False)
	return 'ok'

@add_route('entry.cross', '/cross')
@view_config(route_name = 'entry.cross', renderer = 'string', permission = 'admin')
def cross (request):
	Entry.query.filter_by(id = request.POST['entry_id']).update({"is_crossed": ~ Entry.is_crossed}, synchronize_session=False)
	return 'ok'

@add_route('entry.fold', '/fold')
@view_config(route_name = 'entry.fold', renderer = 'string', permission = 'admin')
def fold (request):
	Entry.query.filter_by(id = request.POST['entry_id']).update({"is_folded": ~ Entry.is_folded}, synchronize_session=False)
	return 'ok'
