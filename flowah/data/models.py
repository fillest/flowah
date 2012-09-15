#coding: utf8
from flowah.data import Reflected, QueryPropertyMixin, ScopedSessionMixin
from sqlalchemy.orm import relationship
from webhelpers.text import chop_at
from webhelpers.html import literal
from mako.filters import html_escape
import re


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

		content = RE_URL.sub(literal(r'<a href="\1">\2</a>'), content)

		return literal(content)

	def tags_to_string (self):
		return self.tags.replace(u'#', u'')
