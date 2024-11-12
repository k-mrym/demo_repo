<?

/**
 * ## Set up basic authentication on the LP pages.
 * @see https://github.com/mpyw-yattemita/php-auth-examples
 * @return string login user name
 * 
 * - Pre-generated password.
 * ```
 * php -r 'echo password_hash("{pass}", PASSWORD_BCRYPT), PHP_EOL;'
 * ```
 * 
 * - user: ZaFFaXkTkg7k
 * - pass: 2Ioo1SopA5klLJgL
 */
function requireBasicAuth()
{
	$hashes = [
		'ZaFFaXkTkg7k' => '$2y$10$kgQpcqI2U6.Wy9o1dI0zqOcfB5JlvzZ49Ubd.t.KCdCcp4i0dyRYa',
	];
	if (
		!isset($_SERVER['PHP_AUTH_USER'], $_SERVER['PHP_AUTH_PW']) ||
		!password_verify(
			$_SERVER['PHP_AUTH_PW'],
			isset($hashes[$_SERVER['PHP_AUTH_USER']])
				? $hashes[$_SERVER['PHP_AUTH_USER']]
				: '$2y$10$NmsBhuM.k6pwopczKcMgI.QnRt7DyEeQ34wWSjdjaBOSPjjI2D81K'
			)
	) {
		// faild Authenticate
		header('WWW-Authenticate: Basic realm="Enter username and password."');
		header('Content-Type: text/plain; charset=utf-8');
		header('X-Robots-Tag: noindex, nofollow');
		exit;
	}
	return $_SERVER['PHP_AUTH_USER'];
}
// Redirect to https when accessing http.
if (empty($_SERVER['HTTPS'])) {
	header("Location: https://{$_SERVER['HTTP_HOST']}{$_SERVER['REQUEST_URI']}");
	exit;
}
// Execute Authentication
$basicAuthenticated = requireBasicAuth();

?>