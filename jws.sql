create
    function jws(first varchar(255), second varchar(255)) returns double
BEGIN

    # For matching
    declare maxString, minString varchar(255);
    declare mi, xi, xn int;
    declare c1 char;
    declare ms1 varchar( 255);
    declare ms2 varchar( 255);
    declare matchFlagsMin, matchFlagsMax varchar( 255);
    declare doBreak boolean;

    # calculations
    declare m, halfTranspositions int;
    declare rangeVal, prefix int;
    declare j, jw double;

    # Constants
    declare defaultScalingFactor float default 0.1;
    declare maxPrefixCount int default 4;

    if (length( first) > length( second)) then
        set maxString = first;
        set minString = second;
    else
        set maxString = second;
        set minString = first;
    end if;

    # Matches -- start
    set rangeVal = GREATEST( length( maxString) / 2 -2, 0);

    set matchFlagsMax = regexp_replace( maxString, "\.", "0");
    set matchFlagsMin = regexp_replace( minString, "\.", "0");

    set mi = 0;
    set m = 0;
    while mi < length( minString) do
            set doBreak = false;

            set c1 = substr(minString, mi+1, 1);
            set xi = GREATEST(mi - rangeVal , 0);
            set xn = LEAST(mi + rangeVal + 1, length( maxString));

            while xi < xn and not doBreak do
                if !substr( matchFlagsMax, xi+1, 1) = '1' and c1 = substr(maxString,xi+1,1) then
                    set m = m +1;
                    set doBreak = true;
                    set matchFlagsMin = insert( matchFlagsMin, mi+1, 1, '1');
                    set matchFlagsMax = insert( matchFlagsMax, xi+1, 1, '1');
                end if;
                set xi = xi +1;
            end while;
            set mi = mi +1;
        end while;

    set mi = 0;

    while mi < length( minString) do
        if substr( matchFlagsMin, mi+1, 1) = 1 then
            set ms1 = CONCAT_WS( '', ms1, substr( minString, mi+1, 1));
        end if;
        set mi = mi +1;
    end while;

    set mi = 0;
    while mi < length( maxString) do
        if (substr( matchFlagsMax, mi+1, 1) = '1') then
            set ms2 = CONCAT_WS('', ms2 , substr( maxString, mi+1, 1));
        end if;
        set mi = mi +1;
    end while;

    set halfTranspositions = 0;
    set mi = 0 ;
    while  mi < length( ms1) do
        if (substr( ms1, mi+1, 1) != substr( ms2, mi+1, 1) ) then
            set halfTranspositions = halfTranspositions +1;

        end if;
        set mi = mi +1;
    end while;

    set prefix = 0;
    set mi = 0;
    set doBreak = false;

    while mi < least( maxPrefixCount, length( minString) ) do
        if( substr(first, mi+1, 1) = substr( second, mi+1, 1) ) then
            set prefix = prefix + 1;
        else
            set mi = 100;
        end if;
        set mi = mi +1 ;
    end while;
    # Matches -- end

    if( m = 0) then
        set j= 0;
    else
        set j = ( m/length(first) + m/length(second) + (m - halfTranspositions/2)/m)/3;
    end if;

    if( j < 0.7) then
        set jw = j;
    else
        set jw = j + defaultScalingFactor * prefix * (1 - j);
    end if;
    return jw;
end;

