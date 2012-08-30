import os
import sapyens.db

from sapyens.db import Reflected

DBSession, QueryPropertyMixin, ScopedSessionMixin = sapyens.db.make_classes(use_zope_ext = True)

def init (engine):
	sapyens.db.init(engine, DBSession, Reflected, on_before_reflect = _on_before_reflect)

def _on_before_reflect ():
	import flowah.data.models
	Reflected.metadata.reflect()  #TODO for n-n tables
