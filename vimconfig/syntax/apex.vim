set syntax=apex

syn region foldBraces start=/{/ end=/}/ transparent fold keepend extend
syn region foldJavadoc start=+/\*+ end=+\*/+ transparent fold keepend extend
