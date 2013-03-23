#coding: utf8
from flowah.data import Reflected, QueryPropertyMixin, ScopedSessionMixin
from sqlalchemy.orm import relationship
from webhelpers.text import chop_at
from webhelpers.html import literal
from mako.filters import html_escape
import re
import urllib


RE_URL = re.compile(r'(https?://([^\s]+))')

class Entry (Reflected, QueryPropertyMixin, ScopedSessionMixin):
	__tablename__ = 'entries'

	parent = relationship('Entry', remote_side = 'Entry.id')

	def render (self, full = False):
		if not full:
			content = chop_at(self.content, '\n')
			if len(self.content) != len(content):
				content += u"(…)"
			content = html_escape(content)
		else:
			content = html_escape(self.content)
			content = self.content.replace('\n', '<br/>')

		def sub_url (m):
			cut_decoded_url = urllib.unquote(m.group(2).encode('utf8')).decode('utf8')
			return literal(r'<a href="%s">%s</a>' % (m.group(1), cut_decoded_url))
		content = RE_URL.sub(sub_url, content)

		return literal(content)

	def tags_to_string (self):
		return self.tags.replace(u'#', u'')
