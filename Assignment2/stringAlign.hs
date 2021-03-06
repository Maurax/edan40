{- 1. If I give Matches high score, mismatches high penalty and no penalty for spaces the 
maximium substring should be all letters that aren't matched to a space.-}

--2.a)
scoreMatch = 0
scoreMissmatch = -1
scoreSpace= -1

string1 = "aferociousmonadatemyhamster"
string2 = "functionalprogrammingrules"

score :: Char -> Char -> Int
score x '-' = scoreSpace
score '-' y = scoreSpace
score x y
    |x==y = scoreMatch
    |otherwise = scoreMissmatch

similarityScore :: String -> String -> Int
similarityScore string1 string2 = sim (string1, string2)

sim :: (String, String) -> Int
sim ([], []) = 0
sim ((x:xs) ,[]) = scoreSpace + sim (xs, [])
sim ([], (y:ys)) = scoreSpace + sim ([], ys)
sim ((x:xs), (y:ys)) = maximum [score x y + sim (xs, ys), score '-' y + sim (xs, ys), 
                        score x '-' + sim (xs, ys)]

--b)
{- 2. b) it takes two elements (h1 and h2) and a list of tuples containing pairs of lists. 
Then it attaches h1 first in every list that's first in the tuples and h2 first in all lists that 
are second in the tuples.

-}        
attachHeads :: a -> a -> [([a],[a])] -> [([a],[a])] 
attachHeads h1 h2 aList = [(h1:xs,h2:ys) | (xs,ys) <- aList]


--c)
maximaBy :: Ord b => (a -> b) -> [a] -> [a] 
maximaBy _ [] = []
maximaBy f (x:xs) 
    |length (maximaBy f xs) == 0 = [x]
    |f x < f (maximaBy f xs !! 0) = maximaBy f xs
    |f x > f (maximaBy f xs !! 0) = [x]
    |otherwise = x:maximaBy f xs
    
--d)  
type AlignmentType = (String,String)

optAlignments :: String -> String -> [AlignmentType]
optAlignments [] [] = [([], [])]
optAlignments (x:xs) [] = attachHeads x '-' $ optAlignments xs []
optAlignments [] (y:ys) = attachHeads '-' y $ optAlignments [] ys
optAlignments (x:xs) (y:ys) = maximaBy sim $ concat [ attachHeads x y (optAlignments xs ys), attachHeads x '-' (optAlignments xs (y:ys)), attachHeads '-' y (optAlignments (x:xs) ys) ]

    
--e)                
outputOptAlignments :: String -> String -> IO()
outputOptAlignments s1 s2 = do printOptAlignments $ optAlignments s1 s2

printOptAlignments :: [AlignmentType] -> IO()

printOptAlignments [] = putStrLn ""
printOptAlignments (s:ss)=do
    putStrLn ""
    putStrLn (fst s)
    putStrLn (snd s)
    printOptAlignments ss

    
--3.
similarityScore2 :: String -> String -> Int
similarityScore2 string1 string2 = sim2 (string1, string2)
    
sim2 :: (String, String) -> Int
sim2 (xs, ys) = simLen (length xs) (length ys)
    where
        simLen :: Int -> Int -> Int
        simLen i j = simTable!!i!!j
        simTable = [[ simEntry i j | j<-[0..]] | i<-[0..]]
        
        simEntry :: Int -> Int -> Int
        simEntry 0 0 = 0
        simEntry i 0 = scoreSpace + simLen (i-1) 0
        simEntry 0 j = scoreSpace + simLen 0 (j-1)
        simEntry i j = maximum [simLen i (j-1) + score x y, simLen (i-1) j + score x y, simLen (i-1) (j-1) + score x y]
            where
                x = xs!!(i-1)
                y = ys!!(j-1)

                
                
optAlignments2 :: String -> String -> [AlignmentType]                
optAlignments2 s1 s2 = snd $ optLen (length s1) (length s2)
    where
        optLen :: Int -> Int -> (Int, [AlignmentType])
        optLen i j = optTable!!i!!j
        optTable = [[ optEntry i j | j<-[0..]] | i<-[0..]]
        
        optEntry :: Int -> Int -> (Int, [AlignmentType])
        optEntry 0 0 = (0, [([], [])])
        optEntry 0 j = (scoreSpace + fst (optLen 0 (j-1)), attachTails '-' (s2!!(j-1)) $ snd $ optEntry 0 (j-1))
        optEntry i 0 = (scoreSpace + fst (optLen (i-1) 0), attachTails (s1!!(i-1)) '-' $ snd $ optEntry (i-1) 0)        
        optEntry i j = (fst $ head f, concatMap snd f)
            where
                x = s1!!(i-1)
                y = s2!!(j-1)
                f = maximaBy fst $ [(score x y + (fst $ optLen (i-1) (j-1)), attachTails x y $ snd $ optLen (i-1) (j-1)), 
                    (score '-' y + (fst $ optLen (i) (j-1)), attachTails '-' y $ snd $ optLen (i) (j-1)), 
                    (score x '-' + (fst $ optLen (i-1) (j)), attachTails x '-' $ snd $ optLen (i-1) (j))]

outputOptAlignments2 :: String -> String -> IO()
outputOptAlignments2 s1 s2 = do printOptAlignments $ optAlignments2 s1 s2
                    
attachTails :: a -> a -> [([a],[a])] -> [([a],[a])]
attachTails h1 h2 aList = [(xs ++ [h1],ys ++ [h2]) | (xs,ys) <- aList]
