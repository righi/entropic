require 'entropy/pool'

$SHA512_REGEX = /^[0-9a-fA-F]{128}$/
$ENTROPY_POOL = Entropy::Pool.instance
