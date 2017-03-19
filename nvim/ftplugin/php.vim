iabbrev <buffer> != !==
iabbrev <buffer> == ===
iabbrev <buffer> fn function
iabbrev <buffer> pubfn public function
iabbrev <buffer> pubstfn public static function
iabbrev <buffer> profn protected function
iabbrev <buffer> prifn private function

if line('$') == 1 && getline(1) == ""
  call setline(1, "<?php")
  call setline(2, "")
  call cursor(2, 1)
endif
