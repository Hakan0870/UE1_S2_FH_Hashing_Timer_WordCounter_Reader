PROGRAM WordCounterO;

USES
    Crt, Timer, WordReader;

CONST
    HashTableSize = 120000;

TYPE
    Element = RECORD
        value: STRING;
        counter: INTEGER;
    END;

    Hash = 1..HashTableSize;
    HashTable = ARRAY[Hash] OF ^Element;


FUNCTION ComputeHash(value: STRING): Hash;
    BEGIN
        IF (Length(value) = 0) THEN
            ComputeHash := 1
        ELSE
            ComputeHash := (ORD(value[1]) MOD HashTableSize) + 1; 
    END; 


PROCEDURE InitHashTable(VAR ht: HashTable);
    VAR
        i: Hash;
    BEGIN
        FOR i := LOW(ht) TO HIGH(ht) DO BEGIN
            ht[i] := NIL;
        END;
    END; 


PROCEDURE DisposeHashTable(VAR ht: HashTable);
    VAR
        i: Hash;
    BEGIN
        FOR i := LOW(ht) TO HIGH(ht) DO BEGIN
            WHILE (ht[i] <> NIL) DO BEGIN
                Dispose(ht[i]);
                ht[i] := NIL;
            END;
        END; 
    END;



PROCEDURE AddToHashTable(VAR ht: HashTable; value: STRING);
    VAR
        i: Hash;
        count: LONGINT;
    BEGIN  
        i := ComputeHash(value);
        count := 0;
        WHILE (ht[i] <> NIL) AND (ht[i]^.value <> value) AND (count < HashTableSize) DO BEGIN
            i := (((i - LOW(ht)) + 1  MOD HashTableSize) + LOW(ht)); 
            INC(count);
        END;
        IF (ht[i] = NIL) THEN BEGIN
            New(ht[i]);
            ht[i]^.value := value;
            ht[i]^.counter := 1;
        END ELSE IF ht[i]^.value = value THEN
            Inc(ht[i]^.counter)  
    END; 


PROCEDURE DisposeWordsOnce(VAR ht: HashTable);
    VAR
        i: Hash;
        n: ^Element;
    BEGIN
        FOR i := LOW(Hash) TO HIGH(Hash) DO BEGIN
            IF (ht[i] <> NIL) AND (ht[i]^.counter = 1) THEN BEGIN
                n := ht[i];
                ht[i] := NIL;
                Dispose(n);
            END;
        END;
    END; 


PROCEDURE WordsMoreThanOnce(ht: HashTable);
    VAR
        i: Hash;
        count: LONGINT;
    
    BEGIN
        count := 0;
        FOR i := LOW(Hash) TO HIGH(Hash) DO BEGIN
            IF ht[i] <> NIL THEN
                INC(count)
        END;
        WriteLn('Number of words more than once: ', count);
    END;



PROCEDURE MostCommonWord(ht : HashTable);
    VAR
        i: Hash;
        mostWordCount: LONGINT;
        mostWord: STRING;
        n: ^Element;
    BEGIN
        mostWordCount := 0;
        mostWord := '';
        FOR i := LOW(Hash) TO HIGH(Hash) DO BEGIN
            n := ht[i];
            IF (n <> NIL) AND (n^.counter > mostWordCount) THEN BEGIN
                mostWord := n^.value;
                mostWordCount := n^.counter;
            END;      
        END; 
        WriteLn('Most common word: ', mostWord,' ', mostWordCount); 
    END;




VAR
    w: Word;
    n: LONGINT;
    ht: HashTable;

BEGIN

    InitHashTable(ht);
    WriteLn;

    WriteLn('WordCounter:');
    OpenFile('Kafka.txt', toLower);
    StartTimer;
    n := 0;
    ReadWord(w);
    WHILE w <> '' DO BEGIN
        n := n + 1;
        AddToHashTable(ht, w);
        (*insert word in data structure and count its occurence*)
        ReadWord(w);
    END;
    StopTimer;
    CloseFile;
    WriteLn('number of words: ', n);
    WriteLn('elapsed time:    ', ElapsedTime);

    MostCommonWord(ht);

    DisposeWordsOnce(ht);
    WordsMoreThanOnce(ht);
    
    DisposeHashTable(ht);  
END. 