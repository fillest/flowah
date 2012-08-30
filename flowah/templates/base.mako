<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />

		<title>
			Flowah
		</title>

        <link rel="stylesheet" href="//netdna.bootstrapcdn.com/twitter-bootstrap/2.0.4/css/bootstrap-combined.min.css" charset="UTF-8" />

        <%block name="links"></%block>

        <script src="//ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js" type="text/javascript" charset="UTF-8"></script>
		<script src="//netdna.bootstrapcdn.com/twitter-bootstrap/2.0.4/js/bootstrap.min.js" type="text/javascript" charset="UTF-8"></script>
		<script src="http://cdn.fillest.ru/coffee-script.1.3.3.min.js" type="text/javascript" charset="UTF-8"></script>
		<script src="//cdnjs.cloudflare.com/ajax/libs/jqueryui/1.8.21/jquery-ui.min.js" type="text/javascript" charset="UTF-8"></script>
    </head>
    <body>
		<div style="text-align: right;">
			%if authenticated_userid(request):
				<a href="${request.route_path('logout')}">Logout</a>
			%endif
		</div>

        ${next.body()}
    </body>
</html>
