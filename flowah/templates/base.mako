<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8" />

		<title>
			Flowah: <%block name="title">untitled</%block>
		</title>

		<link rel="stylesheet" href="http://cdn.fillest.ru/bootstrap.2.1.1/css/bootstrap.min.css" charset="UTF-8" />

		<%block name="links"></%block>

		<script src="http://cdn.fillest.ru/jquery-1.8.1.min.js" type="text/javascript" charset="UTF-8"></script>
		<script src="http://cdn.fillest.ru/bootstrap.2.1.1/js/bootstrap.min.js" type="text/javascript" charset="UTF-8"></script>
		<script src="http://cdn.fillest.ru/coffee-script.1.3.3.min.js" type="text/javascript" charset="UTF-8"></script>
		<script src="http://cdn.fillest.ru/jquery-ui-1.8.23.full.min.js" type="text/javascript" charset="UTF-8"></script>
		<script src="http://cdn.fillest.ru/jquery.cookie.e39cf51.js" type="text/javascript" charset="UTF-8"></script>
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