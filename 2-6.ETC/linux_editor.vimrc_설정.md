# vim 내 기본 설정 - 저장용


```vim
" autoindent 기능 비활성화 (새 줄 생성 시 이전 줄의 들여쓰기를 자동 복사하지 않음)
set noautoindent

" 들여쓰기 계산에 사용되는 표현식을 빈 값으로 설정하여 자동 들여쓰기 식 비활성화
set indentexpr=

" C 언어 스타일의 자동 들여쓰기(cindent) 비활성화
set nocindent

" 스마트 들여쓰기(코드 문맥 기반 들여쓰기) 비활성화
set nosmartindent

" Tab 문자가 차지하는 화면상의 공백 너비를 4칸으로 설정
set tabstop=4

" 자동 들여쓰기나 >>, << 명령어로 이동할 때 사용할 공백 너비를 4칸으로 설정
set shiftwidth=4

" .sh 확장자로 새 파일을 생성하고 저장할 때 실행 권한 부여
" .sh 파일 저장 후(BufWritePost) 백그라운드에서 실행 여부 표시 없이(silent) 해당 파일(<afile>)에 실행 권한 부여(chmod +x)
autocmd BufWritePost *.sh silent !chmod +x <afile>

" .py 확장자에 대해서도 적용하고 싶다면 아래와 같이 추가
" .py 파일 저장 후 백그라운드에서 실행 여부 표시 없이 해당 파일에 실행 권한 부여
autocmd BufWritePost *.py silent !chmod +x <afile>
```