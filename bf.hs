#!/usr/bin/env runhugs

data Bfvm = Bfvm {
	code :: [Char]
,	istr :: Int
,	dmem :: [Char]
,	dpos :: Int
,	ctrl :: [Int]
,	obuf :: [Char]
,	ibuf :: [Char]
	} deriving (Show)


-- fbe [] i j c       = error "empty"
-- fbe ('[':xs) i j c = fbe xs i (succ j) (succ c)
-- fbe (']':xs) i j c =
-- 	if (pred c) == 0
-- 		then (succ j)
-- 		else fbe xs i (succ j) (pred c)
-- fbe (x:xs) i j c   = fbe xs i (succ j) c
-- 
-- findBlockEnd d i = let i2 = succ i in (d, i, fbe (drop i2 d) i2 0 1)

fbe d i j c
	| i >= m || j >= m = error "failed"
	| (d !! j) == '['  = fbe d i j2 (succ c)
	| (d !! j) == ']'  =
		if (pred c) == 0
			then j
			else fbe d i j2 (pred c)
	| otherwise        = fbe d i j2 c
	where
		m = pred $ length d
		j2 = succ j

findBlockEnd d i = let i2 = succ i in fbe d i2 i2 1

vmInit :: [Char] -> [Char] -> Bfvm
vmInit code ib = Bfvm code 0 ['\0', '\0'..] 0 [] "" ib
--vmInit code ib = Bfvm code 0 (replicate 20 '\0') 0 [] "" ib

vmEval :: Bfvm -> [Char]
vmEval vm
	| i >= (length c) = o
	| otherwise       = vmEval $ vmExec vm
	where
		c = code vm
		i = istr vm
		d = dmem vm
		o = obuf vm

vmExec :: Bfvm -> Bfvm
vmExec vm = 
	case (c !! i) of
		'+' -> Bfvm c i2 (take p d ++ [succ $ dd] ++ (drop (succ p) d)) p j ob ib
		'-' -> Bfvm c i2 (take p d ++ [pred $ dd] ++ (drop (succ p) d)) p j ob ib
		'>' -> Bfvm c i2 d (succ p) j ob ib
		'<' -> Bfvm c i2 d (pred p) j ob ib
		'.' -> Bfvm c i2 d p j (ob ++ [dd]) ib
		',' -> if length ib == 0
			then Bfvm c i2 d p j ob ib
			else Bfvm c i2 (take p d ++ [head ib] ++ (drop (succ p) d)) p j ob (tail ib)
		'[' -> if dd == '\0'
			then Bfvm c (findBlockEnd c i2) d p j ob ib
			else Bfvm c i2 d p (i2:j) ob ib
		']' -> if dd == '\0'
			then Bfvm c i2 d p (tail j) ob ib
			else Bfvm c (head j) d p j ob ib
	where 
		c = code vm
		i = istr vm
		i2 = succ i
		d = dmem vm
		p = dpos vm
		dd = d !! p
		j = ctrl vm
		ob = obuf vm
		ib = ibuf vm

progHello = "++++++++++[>+++++++>++++++++++>+++>+<<<<-]>++.>+.+++++++..+++.>++.<<+++++++++++++++.>.+++.------.--------.>+.>."
progCat   = ",[.[-],]"
progJabh  = "+++[>+++++<-]>[>+>+++>+>++>+++++>++<[++<]>---]>->-.[>++>+<<--]>--.--.+.>>>++.<<"
	++ ".<------.+.+++++.>>-.<++++.<--.>>>.<<---.<.-->-.>+.[+++++.---<]>>[.--->]<<.<+.+"
	++ "+.++>+++[.<][.]<++."
progRot13 = "+[,+[-[>+>+<<-]>[<+>-]+>>++++++++[<-------->-]<-[<[-]>>>+[<+<+>>-]<[>+<-]<[<++>"
	++ ">>+[<+<->>-]<[>+<-]]>[<]<]>>[-]<<<[[-]<[>>+>+<<<-]>>[<<+>>-]>>++++++++[<-------"
	++ "->-]<->>++++[<++++++++>-]<-<[>>>+<<[>+>[-]<<-]>[<+>-]>[<<<<<+>>>>++++[<++++++++"
	++ ">-]>-]<<-<-]>[<<<<[-]>>>>[<<<<->>>>-]]<<++++[<<++++++++>>-]<<-[>>+>+<<<-]>>[<<+"
	++ ">>-]+>>+++++[<----->-]<-[<[-]>>>+[<+<->>-]<[>+<-]<[<++>>>+[<+<+>>-]<[>+<-]]>[<]"
	++ "<]>>[-]<<<[[-]<<[>>+>+<<<-]>>[<<+>>-]+>------------[<[-]>>>+[<+<->>-]<[>+<-]<[<"
	++ "++>>>+[<+<+>>-]<[>+<-]]>[<]<]>>[-]<<<<<------------->>[[-]+++++[<<+++++>>-]<<+>"
	++ ">]<[>++++[<<++++++++>>-]<-]>]<[-]++++++++[<++++++++>-]<+>]<.[-]+>>+<]>[[-]<]<]"


main :: IO ()
main = do
	putStr $ vmEval $ vmInit progHello ""
	putStr $ vmEval $ vmInit progCat "this is output\n"
	putStr $ vmEval $ vmInit progJabh ""
	-- putStr $ vmEval $ vmInit progRot13 "roasts" -- ebnfgf
	-- putStr $ vmEval $ vmInit progRot13 "roastsdinnerbananalocustsnovember" -- klybcubarhavdhrsyhssyruvccbpneebg



