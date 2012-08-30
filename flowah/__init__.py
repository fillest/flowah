from pyramid.config import Configurator
from sqlalchemy import engine_from_config
import flowah.data
import pyramid.session
import pyramid.authorization
import pyramid.authentication
import pyramid.security
from pyramid.events import BeforeRender, subscriber
from pyramid.security import authenticated_userid, has_permission
import pyramid.tweens
import sapyens.views


def main (global_config, **settings):
	flowah.data.init(engine_from_config(settings, 'sqlalchemy.'))

	config = Configurator(
		settings = settings,
		root_factory = RootFactory,
		session_factory = pyramid.session.UnencryptedCookieSessionFactoryConfig(
			settings.get('session.secret', 'test'),
			cookie_name = settings.get('session.cookie.name', 's'),
			timeout = 60*60*24*3,
			cookie_max_age = 60*60*24*3,
		),
		authentication_policy = pyramid.authentication.SessionAuthenticationPolicy(
			prefix = 'auth.',
			callback = group_finder,
			debug = False),
		authorization_policy = pyramid.authorization.ACLAuthorizationPolicy(),
	)

	config.set_request_property(
		lambda request: lambda permission: has_permission(permission, request.root, request),
		'has_permission'
	)

	config.add_tween('sapyens.db.notfound_tween_factory', under = pyramid.tweens.EXCVIEW)

	config.add_static_view('static', 'static', cache_max_age=3600)

	config.add_route('login', '/login')
	login_view = sapyens.views.LoginView(lambda _, request: request.registry.settings['password'])
	config.add_view(login_view, route_name = 'login', renderer = 'sapyens.views:templates/login.mako')
	config.add_forbidden_view(login_view, renderer = 'sapyens.views:templates/login.mako')
	config.add_route('logout', '/logout')
	config.add_view(sapyens.views.LogoutView('root'), route_name = 'logout', permission = 'view')

	config.scan()

	return config.make_wsgi_app()


class RootFactory (object):
	__acl__ = [
		(pyramid.security.Allow, 'group:admin', pyramid.security.ALL_PERMISSIONS),
	]

	def __init__ (self, request):
		pass

@subscriber(BeforeRender)
def _add_renderer_globals (event):
	event['authenticated_userid'] = authenticated_userid

def group_finder (userid, request):
	return ['group:admin'] if userid == 'admin' else []
