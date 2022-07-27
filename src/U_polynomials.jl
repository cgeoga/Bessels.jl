besseljy_debye_cutoff(nu, x) = nu > 2.0 + 1.00035*x + Base.Math._approx_cbrt(Float64(302.681)*x) && x > 15
# valid when x < v (uniform asymptotic expansions)
"""
    besseljy_debye(nu, x::T)

Debey's asymptotic expansion for large order valid when v-> ∞ and x < v.
Returns both besselj and bessely
"""
function besseljy_debye(v, x)
    T = eltype(x)
    S = promote_type(T, Float64)
    x = S(x)

    vmx = (v + x) * (v - x)
    vs = sqrt(vmx)
    sqvs = inv(sqrt(vs))
    n  = muladd(v, -log(x / (v + vs)), -vs)

    coef_Jn = SQ1O2PI(S) * exp(-n) * sqvs
    coef_Yn = -SQ2OPI(S) * exp(n) * sqvs

    p = v / vs
    p2  = v^2 / vmx

    Uk_Jn, Uk_Yn = Uk_poly_Jn(p, v, p2, x)

    return coef_Jn * Uk_Jn, coef_Yn * Uk_Yn
end
# valid when v < x (uniform asymptotic expansions)
"""
    hankel_debye(nu, x::T)

Debey's asymptotic expansion for large order valid when v < x.
Return the Hankel function H(nu, x) = J(nu, x) + Y(nu, x)*im
"""
function hankel_debye(v, x::T) where T
    S = promote_type(T, Float64)
    x = S(x)

    vmx = abs((v + x) * (x - v))
    vs = sqrt(vmx)
    sqvs = inv(sqrt(vs))
    n  = vs - v*acos(v/x) - PIO4(S)

    coef_Yn = SQ2OPI(S) * exp(n*im) * sqvs

    p = v / vs
    p2  = v^2 / vmx

    _, Uk_Yn = Uk_poly_Jn(p*im, v, -p2, x)

    return coef_Yn * Uk_Yn
end

function Uk_poly_Jn(p, v, p2, x::T) where T <: Float64
    if v > 5.0 + 1.00033*x + Base.Math._approx_cbrt(1427.61*x)
        return Uk_poly10(p, v, p2)
    else
        return Uk_poly20(p, v, p2)
    end
end

Uk_poly_In(p, v, p2, ::Type{Float32}) = Uk_poly3(p, v, p2)[1]
Uk_poly_In(p, v, p2, ::Type{Float64}) = Uk_poly5(p, v, p2)[1]
Uk_poly_Kn(p, v, p2, ::Type{Float32}) = Uk_poly3(p, v, p2)[2]
Uk_poly_Kn(p, v, p2, ::Type{Float64}) = Uk_poly5(p, v, p2)[2]

@inline function split_evalpoly(x, P)
    # polynomial P must have an even number of terms
    N = length(P)
    xx = x*x

    out = P[end]
    out2 = P[end-1]

    for i in N-2:-2:2
        out = muladd(xx, out, P[i])
        out2 = muladd(xx, out2, P[i-1])
    end
    if iszero(rem(N, 2))
        out *= x
        return out2 - out, out2 + out
    else 
        out = muladd(xx, out, P[1])
        out2 *= x
        return out - out2, out2 + out
    end
end

function Uk_poly3(p, v, p2)
    u0 = 1.0
    u1 = evalpoly(p2, (0.125, -0.20833333333333334))
    u2 = evalpoly(p2, (0.0703125, -0.4010416666666667, 0.3342013888888889))
    u3 = evalpoly(p2, (0.0732421875, -0.8912109375, 1.8464626736111112, -1.0258125964506173))

    Poly = (u0, u1, u2, u3)

   return split_evalpoly(-p/v, Poly)
end
function Uk_poly5(p, v, p2)
    u0 = 1.0
    u1 = evalpoly(p2, (0.125, -0.20833333333333334))
    u2 = evalpoly(p2, (0.0703125, -0.4010416666666667, 0.3342013888888889))
    u3 = evalpoly(p2, (0.0732421875, -0.8912109375, 1.8464626736111112, -1.0258125964506173))
    u4 = evalpoly(p2, (0.112152099609375, -2.3640869140625, 8.78912353515625, -11.207002616222994, 4.669584423426247))
    u5 = evalpoly(p2, (0.22710800170898438, -7.368794359479632, 42.53499874538846, -91.81824154324002, 84.63621767460073, -28.212072558200244))
    
    Poly = (u0, u1, u2, u3, u4, u5)
    return split_evalpoly(-p/v, Poly)
end

function Uk_poly10(p, v, p2)
    u0 = 1.0
    u1 = evalpoly(p2, (0.125, -0.20833333333333334))
    u2 = evalpoly(p2, (0.0703125, -0.4010416666666667, 0.3342013888888889))
    u3 = evalpoly(p2, (0.0732421875, -0.8912109375, 1.8464626736111112, -1.0258125964506173))
    u4 = evalpoly(p2, (0.112152099609375, -2.3640869140625, 8.78912353515625, -11.207002616222994, 4.669584423426247))
    u5 = evalpoly(p2, (0.22710800170898438, -7.368794359479632, 42.53499874538846, -91.81824154324002, 84.63621767460073, -28.212072558200244))
    u6 = evalpoly(p2, (0.5725014209747314, -26.491430486951554, 218.1905117442116, -699.5796273761325, 1059.9904525279999, -765.2524681411817, 212.57013003921713))
    u7 = evalpoly(p2, (1.7277275025844574, -108.09091978839466, 1200.9029132163525, -5305.646978613403, 11655.393336864534, -13586.550006434136, 8061.722181737309, -1919.457662318407))
    u8 = evalpoly(p2, (6.074042001273483, -493.91530477308805, 7109.514302489364, -41192.65496889755, 122200.46498301747, -203400.17728041555, 192547.00123253153, -96980.59838863752, 20204.29133096615))
    u9 = evalpoly(p2, (24.380529699556064, -2499.8304818112097, 45218.76898136273, -331645.17248456355, 1.2683652733216248e6, -2.8135632265865337e6, 3.763271297656404e6, -2.998015918538107e6, 1.3117636146629772e6, -242919.18790055133))
    u10 = evalpoly(p2, (110.01714026924674, -13886.08975371704, 308186.40461266245, -2.7856181280864547e6, 1.3288767166421818e7, -3.7567176660763346e7, 6.634451227472903e7, -7.410514821153265e7, 5.095260249266464e7, -1.9706819118432228e7, 3.284469853072038e6))

    Poly = (u0, u1, u2, u3, u4, u5, u6, u7, u8, u9, u10)
    return split_evalpoly(-p/v, Poly)
end

function Uk_poly20(p, v, p2)
    u0 = 1.0
    u1 = evalpoly(p2, (0.125, -0.20833333333333334))
    u2 = evalpoly(p2, (0.0703125, -0.4010416666666667, 0.3342013888888889))
    u3 = evalpoly(p2, (0.0732421875, -0.8912109375, 1.8464626736111112, -1.0258125964506173))
    u4 = evalpoly(p2, (0.112152099609375, -2.3640869140625, 8.78912353515625, -11.207002616222994, 4.669584423426247))
    u5 = evalpoly(p2, (0.22710800170898438, -7.368794359479632, 42.53499874538846, -91.81824154324002, 84.63621767460073, -28.212072558200244))
    u6 = evalpoly(p2, (0.5725014209747314, -26.491430486951554, 218.1905117442116, -699.5796273761325, 1059.9904525279999, -765.2524681411817, 212.57013003921713))
    u7 = evalpoly(p2, (1.7277275025844574, -108.09091978839466, 1200.9029132163525, -5305.646978613403, 11655.393336864534, -13586.550006434136, 8061.722181737309, -1919.457662318407))
    u8 = evalpoly(p2, (6.074042001273483, -493.91530477308805, 7109.514302489364, -41192.65496889755, 122200.46498301747, -203400.17728041555, 192547.00123253153, -96980.59838863752, 20204.29133096615))
    u9 = evalpoly(p2, (24.380529699556064, -2499.8304818112097, 45218.76898136273, -331645.17248456355, 1.2683652733216248e6, -2.8135632265865337e6, 3.763271297656404e6, -2.998015918538107e6, 1.3117636146629772e6, -242919.18790055133))
    u10 = evalpoly(p2, (110.01714026924674, -13886.08975371704, 308186.40461266245, -2.7856181280864547e6, 1.3288767166421818e7, -3.7567176660763346e7, 6.634451227472903e7, -7.410514821153265e7, 5.095260249266464e7, -1.9706819118432228e7, 3.284469853072038e6))
    u11 = evalpoly(p2, (551.3358961220206, -84005.4336030241, 2.2437681779224495e6, -2.4474062725738727e7, 1.420629077975331e8, -4.9588978427503026e8, 1.1068428168230145e9, -1.6210805521083372e9, 1.5535968995705802e9, -9.394623596815784e8, 3.2557307418576574e8, -4.932925366450996e7))
    u12 = evalpoly(p2, (3038.090510922384, -549842.3275722887, 1.7395107553978164e7, -2.2510566188941526e8, 1.5592798648792574e9, -6.563293792619285e9, 1.79542137311556e10, -3.3026599749800724e10, 4.1280185579753975e10, -3.4632043388158775e10, 1.8688207509295826e10, -5.866481492051847e9, 8.147890961183121e8))
    u13 = evalpoly(p2, (18257.755474293175, -3.8718334425726123e6, 1.43157876718889e8, -2.167164983223795e9, 1.763473060683497e10, -8.786707217802327e10, 2.879006499061506e11, -6.453648692453765e11, 1.0081581068653821e12, -1.0983751560812233e12, 8.192186695485773e11, -3.990961752244665e11, 1.144982377320258e11, -1.4679261247695616e10))
    u14 = evalpoly(p2, (118838.42625678326, -2.9188388122220814e7, 1.2470092935127103e9, -2.1822927757529224e10, 2.0591450323241e11, -1.1965528801961816e12, 4.612725780849132e12, -1.2320491305598287e13, 2.334836404458184e13, -3.166708858478516e13, 3.056512551993532e13, -2.0516899410934438e13, 9.109341185239898e12, -2.406297900028504e12, 2.86464035717679e11))   
    u15 = evalpoly(p2, (832859.3040162893, -2.3455796352225152e8, 1.1465754899448236e10, -2.2961937296824646e11, 2.4850009280340854e12, -1.663482472489248e13, 7.437312290867914e13, -2.3260483118893994e14, 5.230548825784446e14, -8.57461032982895e14, 1.0269551960827625e15, -8.894969398810265e14, 5.4273966498765975e14, -2.213496387025252e14, 5.417751075510605e13, -6.019723417234006e12))
    u16 = evalpoly(p2, (6.252951493434797e6, -2.0016469281917763e9, 1.1099740513917902e11, -2.5215584749128545e12, 3.100743647289646e13, -2.3665253045164925e14, 1.2126758042503475e15, -4.3793258383640155e15, 1.1486706978449752e16, -2.2268225133911144e16, 3.213827526858624e16, -3.4447226006485144e16, 2.705471130619708e16, -1.5129826322457682e16, 5.705782159023671e15, -1.3010127235496995e15, 1.3552215870309369e14))
    u17 = evalpoly(p2, (5.0069589531988926e7, -1.8078220384658062e10, 1.128709145410874e12, -2.886383763141476e13, 4.0004445704303625e14, -3.4503855118462725e15, 2.0064271476309532e16, -8.270945651585064e16, 2.4960365126160426e17, -5.62631788074636e17, 9.575335098169139e17, -1.2336116931960694e18, 1.1961991142756308e18, -8.592577980317548e17, 4.4347954614171904e17, -1.5552983504313904e17, 3.3192764720355224e16, -3.254192619642669e15))
    u18 = evalpoly(p2, (4.259392165047669e8, -1.722832387173505e11, 1.2030115826419191e13, -3.4396530474307594e14, 5.335106978708839e15, -5.1605093193485224e16, 3.37667624979061e17, -1.5736434765189599e18, 5.402894876715982e18, -1.3970803516443374e19, 2.757282981650519e19, -4.178861444656839e19, 4.859942729324836e19, -4.301555703831444e19, 2.846521225167657e19, -1.3639420410571592e19, 4.47020096401231e18, -8.966114215270463e17, 8.30195760673191e16))
    u19 = evalpoly(p2, (3.8362551802304335e9, -1.7277040123529995e12, 1.3412416915180639e14, -4.2619355104268985e15, 7.351663610930971e16, -7.921651119323832e17, 5.789887667664653e18, -3.025566598990372e19, 1.1707490535797259e20, -3.434621399768417e20, 7.756704953461136e20, -1.360203777284994e21, 1.8571089321463453e21, -1.9677247077053125e21, 1.6016898573693598e21, -9.824438427689858e20, 4.392792200888712e20, -1.351217503435996e20, 2.5563802960529236e19, -2.242438856186775e18))
    u20 = evalpoly(p2, (3.646840080706556e10, -1.818726203851104e13, 1.5613123930484672e15, -5.48403360388329e16, 1.0461721131134344e18, -1.2483700995047234e19, 1.0126774169536592e20, -5.8917941350694964e20, 2.548961114664972e21, -8.405915817108351e21, 2.1487414815055883e22, -4.302534303482379e22, 6.783661642951883e22, -8.423222750084323e22, 8.19433100543513e22, -6.173206302884415e22, 3.528435843903409e22, -1.4787743528433614e22, 4.285296082829494e21, -7.671943936729004e20, 6.393286613940837e19))

    Poly = (u0, u1, u2, u3, u4, u5, u6, u7, u8, u9, u10, u11, u12, u13, u14, u15, u16,  u17, u18, u19, u20)
    return split_evalpoly(-p/v, Poly)
end

function Uk_poly_Jn(p, v, p2, x::T) where T <: BigFloat
    u0 = one(T)
    u1 = evalpoly(p2, (3, -5)) / 24
    u2 = evalpoly(p2, (81, -462, 385)) / 1152
    u3 = evalpoly(p2, (30375, -369603, 765765, -425425)) / 414720
    u4 = evalpoly(p2, (4465125, -94121676, 349922430, -446185740, 185910725)) / 39813120
    u5 = evalpoly(p2, (1519035525, -49286948607, 284499769554, -614135872350, 566098157625, -188699385875)) / 6688604160
    u6 = evalpoly(p2, (2757049477875, -127577298354750, 1050760774457901, -3369032068261860,5104696716244125, -3685299006138750, 1023694168371875)) / 4815794995200
    u7 = evalpoly(p2, (199689155040375, -12493049053044375, 138799253740521843, -613221795981706275, 1347119637570231525, -1570320948552481125, 931766432052080625,  -221849150488590625)) / 115579079884800
    u8 = evalpoly(p2, (134790179652253125, -10960565081605263000, 157768535329832893644, -914113758588905038248, 2711772922412520971550, -4513690624987320777000, 4272845805510421639500, -2152114239059719935000, 448357133137441653125)) / 22191183337881600
    u9 = evalpoly(p2, (6427469716717690265625, -659033454841709672064375, 11921080954211358275362500, -87432034049652400520788332, 334380732677827878090447630, -741743213039573443221773250, 992115946599792610768672500, -790370708270219620781737500, 345821892003106984030190625, -64041091111686478524109375)) / 263631258054033408000
    u10 = evalpoly(p2, (9745329584487361980740625, -1230031256571145165088463750, 27299183373230345667273718125, -246750339886026017414509498824, 1177120360439828012193658602930, -3327704366990695147540934069220, 5876803711285273203043452095250, -6564241639632418015173104205000, 4513386761946134740461797128125, -1745632061522350031610173343750, 290938676920391671935028890625)) / 88580102706155225088000
    u11 = evalpoly(p2, (15237265774872558064250728125, -2321657500166464779660536015625, 62011003282542082472252466220875, -676389476843440422173605288596087, 3926191452593448964331218647028194, -13704902022868787041097596217578170, 30589806122850866110941936529264950, -44801790321820682384740638703320750, 42936745153513007436411401865860625, -25963913760458280822131901737878125, 8997860461116953237934638500359375, -1363312191078326248171914924296875)) / 27636992044320430227456000
    u12 = evalpoly(p2, (120907703923613748239829527671875, -21882222767154197351962677311437500, 692277766674325563109617997687563750, -8958590476947726766450604043798559500, 62055079517573388459132793029571876461, -261201165596865827608687437905740780920, 714528665351965363868467348116538170900, -1314368459332124683504418467809129387000, 1642838631056253395899341314188134178125, -1378260730939829908037976894025628887500, 743739612850105971846901081692858843750, -233469939346545526651936774615688437500, 32426380464797989812768996474401171875)) / 39797268543821419527536640000
    u13 = evalpoly(p2, (17438611142828905996129258798828125, -3698121486504259988094897605296209375, 136735019134677724428035696765082813750, -2069933923586966756183324291232117362250, 16843538631795795357786827345307534156063, -83924867223075156862785921508524155665245, 274983827478138958623041508409195988431140, -616410216242554698436702353237166008656700, 962926533925253374359704288384340809260875, -1049095945162229046324321461816274931715625, 782463969315283937856703223178540650343750, -381190503845282445953419057314665534156250, 109361210755577700442544717509565392265625, -14020668045586884672121117629431460546875)) / 955134445051714068660879360000
    u14 = evalpoly(p2, (5448320367052402487647812713291015625, -1338184074771428116079233795614103631250, 57170953417612444837142230812990944671875, -1000503839668383458999731491914516564625300, 9440449669103391509091075981237243128469201, -54857705817658080981995319669299096598482382, 211477117385619365164298957821904115470535555, -564850830044980230366140582063618983657685400, 1070439683260179398514645952824098811025619475, -1451823699927947602004297385351260623500372750, 1401302601668131482630653233972052729323190625, -940627071986145750405920450097257805227812500, 417630985812040040477569028872405152769921875, -110320224449895843354117801955418504167031250, 13133360053559028970728309756597440972265625)) / 45846453362482275295722209280000
    u15 = evalpoly(p2, (8178936810213560828419581728001773291015625, -2303431987527333128955769182299845911305390625, 112597271053778779753048514469995937998172890625, -2254933495791765108580529087615802250458013685625, 24403480234538299231733883413666768614198435948125, -163359140754958502896104062604202934925448173291477, 730367145705123976114617970888707594104468177381925, -2284251621937242886581917667066122422330060024456125, 5136561256208409671660362298619778869859994724706875, -8420533422834140468835467666391400380550043688871875, 10085018700249896522602267572484630409640764997271875, -8735135969643867540297524795790262235822823374296875, 5329871927856528282113994744458999865006055974609375, -2173722139119126857509156976742601742357422740234375, 532039967451707060045861997017872377315039521484375, -59115551939078562227317999668652486368337724609375)) / 9820310310243703368343697227776000000
    u16 = evalpoly(p2, (23579874823845695868333654121829112397998046875, -7548208883093506123919073318645848440986281250000, 418571121445853600940987397062487467273966779625000, -9508794888602532435079114127493385198079570710470000, 116929016866180520574682795493722856433879981336112500, -892416493340003758691506680694321990355675722520838096, 4572999438129700505777642155788222350797540050279284760, -16514434054042671665093745143345645271999901089177788400, 43316362356947864694367448897560019067412728259897505250, -83973458255376217113431722753277764119484494850353270000, 121193409013842312774251134029225218007034205572281375000, -129900460304939941764670297010274798325693206430601250000, 102023293586271009821923530738271106285703628596295312500, -57054562339825052419659481088225652020508564894843750000, 21516499723877657209702638528530839860502345904015625000, -4906117886528008036369575428500807148681084440781250000, 511053946513334170455164107135500744654279629248046875)) / 3770999159133582093443979735465984000000
    u17 = evalpoly(p2, (86098445290621992919710288959076381992996044921875, -31086866964344776434901340294726759585844523939453125, 1940900724642360326780559417863159500982538936987375000, -49633551391469586967911551642521760042791355027620125000, 687906693873155071735691272079937403263685738018470814500, -5933198793919698447982330692598158428032189878414161012124, 34502031994800767344892422746634773296018107824906632419848, -142225164683992765990030747899409462088308925365682017857240, 429212352515026773475471295511415883382060846328770993005250, -967487903877461958325237917115228310512630590714451916640750, 1646551275524985252738847924398650627672209050734790851265000, -2121288587929318041669932345514745412624685501425210767875000, 2056954829464921151146089484749565775448230537475447606562500, -1477558757838664620053280135342775196503230238657956773437500, 762596613990574496129519527341431797422236075424587596875000, -267445311988545069854943494211913506927580321987738265625000, 57077468859498937494621367436714109067308943816271513671875, -5595830280343033087707977199677853830128327825124658203125)) / 1719575616564913434610454759372488704000000
    u18 = evalpoly(p2, (17402648254366970318896442155853313710334325579833984375, -7038996381042630440706320955207218277836259136214144531250, 491515845627995608630308828025937223574193727753376100859375, -14053430579296992819276840860026711644143962037898462198750000, 217977088167107844476671248240850549184342689357081793983627500, -2108435312318793739666233505677933977608124223061200130648299000, 13796125542556918366536045481173150324297945459901440053845493532, -64294535084989436534160300189785402934009324116808204634140090960, 220746706223415685134843293656748091845034254294736425040548604450, -570806748959722117700578156666367879819767325936645047354739587500, 1126546324172034608288726239622146620694308510621969350884171781250, -1707362295067866555400074337741150183369276187369879432556935250000, 1985632470023144029098600377248581775333320983961309350778555937500, -1757491631661175749558620292180560395062012011157079033996696875000, 1163006497421870129179321717633624986894646606476886508372367187500, -557267390747417776045984733477369082240579802825315540376718750000, 182639522233726398821209338567430722027981720466294556325849609375, -36632957438678377189819992330283878474735514770655121685644531250, 3391940503581331221279628919470729488401436552838437193115234375)) / 40857116649582343206344405082690331607040000000
    u19 = evalpoly(p2, (3761719809509744584195141470215239968860161850335693359375, -1694136104847790923543013061207680485991618397125797873046875, 131518243789528012257323287684549590712219590887856743595703125, -4179129511260217209133623104486559148268490002722848244991240625, 72088266652871136165181276891337618088740053757385007292240377500, -776773977214820033621339638022401758862209813648991378355261599500, 5677394779818071523358076045292335690018332546439714641415150037636, -29667822591847140970922062603154078948366431649274897672067206014580, 114800233558787974267088388638654159779991991716667850063043161177890, -336788945225975997668966486515468748933754942064781256509404101275850, 760599837839891632010677514872412397427959022966733699428711208643750, -1333776105497652608917805362422659621440699261908512326717363285968750, 1821026790520428617034899967974569000414933301802005578083458082187500, -1929493390007550512825649545883182667978851358936168551128507440937500, 1570570304135828069768211937927131121377451398878663909061910457812500, -963355744456233323886326422779275308259891167457840027230510476562500, 430744376085805585076333464506126217301082462279781595185335615234375, -132496442776420617057548516091451843431549350710841121872822607421875, 25067118709566753991500713640672585065184296412786618544560205078125, -2198870062242697718552694179006367110981078632700580574084228515625)) / 980570799589976236952265721984567958568960000000
    u20 = evalpoly(p2, (24030618487110150352755402740028995969072485932314476318359375, -11984379509393886990049682627416290126645799829432886859195312500, 1028816773596376675865176501621547688509187479681533744365175781250, -36136687211104276266628386141898079997731413843884113675698994212500, 689368394712060288513879526213143279387995331221181709158682715671875, -8226054591925395046897310265711439061232478740113589342810359827971600, 66729727980314206345594148553023187689855688854650386958448499394886808, -388235990422199036481157075090292917209702371811112714609151030385239376, 1679621555358289731717827244171539003686077073065087747585589973854567950, -5539024239213671573375139503069183935283937579486175606155069574939719000, 14158993985687610069291256086138044030538819617545349322200892501730615500, -28351273454978996507857547213496220444080209057761228571819950144231575000, 44700502703654649774362294361156754154712937287563245669685024068473468750, -55504285315413734114196925709059066734450069228526494661323483726671250000, 53996017865021964397812742861916826936440170527545458081631955240159375000, -40677946447845849750014263157052100427921007881029648608310681741346250000, 23250401373415767366970579801426233116241475047289980901600427561701171875, -9744288621182737996606001891415854305391392962559389056448157541132812500, 2823768330714179467082676027577350697536971031741905897356560592675781250, -505537818270094147077012813306995849751437826286925078626556809570312500, 42128151522507845589751067775582987479286485523910423218879734130859375)) / 658943577324464031231922565173629668158341120000000
    u21 = evalpoly(p2, (1990919576929585163761247434580873723897677550573731281207275390625, -1094071724893410272201314846735800345180930752601602224440504638671875, 103359845691236916270005420886293061281368263471845448279855946394531250, -3993558675585831919973605001813276532326292885934464373884268722794718750, 83832389176247515253189196480455786065824463879054932596114704927571390625, -1101977288759423115916484463959767795703317649005495798822550381533967842875, 9865413224996821913093061266347613112205666995211786544733850490740903131000, -63509799534443193918054738326913581450607131662586232327271654588312820660616, 305080179205137176095342856930260393560550505786421683990077008259370104309410, -1122099959965657526344757894103766710826629020929459670948834078441128579791750, 3217185258543282976637373169047731813093578126603884759856059695249999306047500, -7276835259402589085458442196686990645669654847254510877738804991391058411412500, 13076651508858985557227319801010895818335803028865299751194038965212274849406250, -18719023753854332443081892087572754119280558462994056787647908433841920235468750, 21307327225910629020600045595173860611314592374884901403059587980149276271875000, -19156728115567236234371593788102013666866274144599851347429312225076676478125000, 13430107219321888006291381503763318985372222835071804983658005207838642173828125, -7186150593017474773099947110903785965879266917528290917207712073663895771484375, 2834031566467842832851805860262261718160136985649155528263587796394390332031250, -776308737033643856044315139790308583914612827783322139063211433790569824218750, 131897976398031751060811874321878385924211075364673046295410087596954345703125, -10468093364923154846096180501736379835254847251164527483762705364837646484375)) / 5456052820246562178600318839637653652351064473600000000
    
    Poly = (u0, u1, u2, u3, u4, u5, u6, u7, u8, u9, u10, u11, u12, u13, u14, u15, u16,  u17, u18, u19, u20, u21)
    return split_evalpoly(-p/v, Poly)
end
#=
    u0 = one(x)
    u1 = p / 24 * (3 - 5*p^2) * -1 / v
    u2 = p^2 / 1152 * (81 - 462*p^2 + 385*p^4) / v^2
    u3 = p^3 / 414720 * (30375 - 369603 * p^2 + 765765*p^4 - 425425*p^6) * -1 / v^3
    u4 = p^4 / 39813120 * (4465125 - 94121676*p^2 + 349922430*p^4 - 446185740*p^6 + 185910725*p^8) / v^4
    u5 = p^5 / 6688604160 * (-188699385875*p^10 + 566098157625*p^8 - 614135872350*p^6 + 284499769554*p^4 - 49286948607*p^2 + 1519035525) * -1 / v^5
    u6 = p^6 / 4815794995200 * (1023694168371875*p^12 - 3685299006138750*p^10 + 5104696716244125*p^8 - 3369032068261860*p^6 + 1050760774457901*p^4 - 127577298354750*p^2 + 2757049477875) * 1 / v^6
    u7 = p^7 / 115579079884800 * (-221849150488590625*p^14 + 931766432052080625*p^12 - 1570320948552481125*p^10 + 1347119637570231525*p^8 - 613221795981706275*p^6 + 138799253740521843*p^4 - 12493049053044375*p^2 + 199689155040375) * -1 / v^7
    u8 = p^8 / 22191183337881600 * (448357133137441653125*p^16 - 2152114239059719935000*p^14 + 4272845805510421639500*p^12 - 4513690624987320777000*p^10 + 2711772922412520971550*p^8 - 914113758588905038248*p^6 + 157768535329832893644*p^4 - 10960565081605263000*p^2 + 134790179652253125) * 1 / v^8
    u9 = p^9 / 263631258054033408000 * (-64041091111686478524109375*p^18 + 345821892003106984030190625*p^16 - 790370708270219620781737500*p^14 + 992115946599792610768672500*p^12 - 741743213039573443221773250*p^10 + 334380732677827878090447630*p^8 - 87432034049652400520788332*p^6 + 11921080954211358275362500*p^4 - 659033454841709672064375*p^2 + 6427469716717690265625) * -1 / v^9
    u10 = p^10 / 88580102706155225088000 * (290938676920391671935028890625*p^20 - 1745632061522350031610173343750*p^18 + 4513386761946134740461797128125*p^16 - 6564241639632418015173104205000*p^14 + 5876803711285273203043452095250*p^12 - 3327704366990695147540934069220*p^10 + 1177120360439828012193658602930*p^8 - 246750339886026017414509498824*p^6 + 27299183373230345667273718125*p^4 - 1230031256571145165088463750*p^2 + 9745329584487361980740625) * 1 / v^10
    u11 = p^11 / 27636992044320430227456000 * (-1363312191078326248171914924296875*p^22 + 8997860461116953237934638500359375*p^20 - 25963913760458280822131901737878125*p^18 + 42936745153513007436411401865860625*p^16 - 44801790321820682384740638703320750*p^14 + 30589806122850866110941936529264950*p^12 - 13704902022868787041097596217578170*p^10
        + 3926191452593448964331218647028194*p^8 - 676389476843440422173605288596087*p^6 + 62011003282542082472252466220875*p^4 - 2321657500166464779660536015625*p^2 + 15237265774872558064250728125) * -1 / v^11
    u12 = p^12 / 39797268543821419527536640000 * (32426380464797989812768996474401171875*p^24 - 233469939346545526651936774615688437500*p^22 + 743739612850105971846901081692858843750*p^20 - 1378260730939829908037976894025628887500*p^18 + 1642838631056253395899341314188134178125*p^16 - 1314368459332124683504418467809129387000*p^14
        + 714528665351965363868467348116538170900*p^12 - 261201165596865827608687437905740780920*p^10 + 62055079517573388459132793029571876461*p^8 - 8958590476947726766450604043798559500*p^6 + 692277766674325563109617997687563750*p^4 - 21882222767154197351962677311437500*p^2 + 120907703923613748239829527671875) * 1 / v^12
    u13 = p^13 / 955134445051714068660879360000 * (-14020668045586884672121117629431460546875*p^26 + 109361210755577700442544717509565392265625*p^24 - 381190503845282445953419057314665534156250*p^22 + 782463969315283937856703223178540650343750*p^20
        - 1049095945162229046324321461816274931715625*p^18 + 962926533925253374359704288384340809260875*p^16 - 616410216242554698436702353237166008656700*p^14 + 274983827478138958623041508409195988431140*p^12 - 83924867223075156862785921508524155665245*p^10
        + 16843538631795795357786827345307534156063*p^8 - 2069933923586966756183324291232117362250*p^6 + 136735019134677724428035696765082813750*p^4 - 3698121486504259988094897605296209375*p^2 + 17438611142828905996129258798828125) * -1 / v^13
    u14 = p^14 / 45846453362482275295722209280000 * (13133360053559028970728309756597440972265625*p^28 - 110320224449895843354117801955418504167031250*p^26 + 417630985812040040477569028872405152769921875*p^24
        - 940627071986145750405920450097257805227812500*p^22 + 1401302601668131482630653233972052729323190625*p^20 - 1451823699927947602004297385351260623500372750*p^18 + 1070439683260179398514645952824098811025619475*p^16
        - 564850830044980230366140582063618983657685400*p^14 + 211477117385619365164298957821904115470535555*p^12 - 54857705817658080981995319669299096598482382*p^10 + 9440449669103391509091075981237243128469201*p^8
        - 1000503839668383458999731491914516564625300*p^6 + 57170953417612444837142230812990944671875*p^4 - 1338184074771428116079233795614103631250*p^2 + 5448320367052402487647812713291015625) * 1 / v^14
    u15 = p^15 / 9820310310243703368343697227776000000 * (- 59115551939078562227317999668652486368337724609375*p^30 + 532039967451707060045861997017872377315039521484375*p^28 - 2173722139119126857509156976742601742357422740234375*p^26
        + 5329871927856528282113994744458999865006055974609375*p^24 - 8735135969643867540297524795790262235822823374296875*p^22 + 10085018700249896522602267572484630409640764997271875*p^20 - 8420533422834140468835467666391400380550043688871875*p^18
        + 5136561256208409671660362298619778869859994724706875*p^16 - 2284251621937242886581917667066122422330060024456125*p^14 + 730367145705123976114617970888707594104468177381925*p^12 - 163359140754958502896104062604202934925448173291477*p^10
        + 24403480234538299231733883413666768614198435948125*p^8 - 2254933495791765108580529087615802250458013685625*p^6 + 112597271053778779753048514469995937998172890625*p^4 - 2303431987527333128955769182299845911305390625*p^2 + 8178936810213560828419581728001773291015625) * -1 / v^15

function Uk_poly_Jn(p, v, p2, ::Type{T}) where T <: Float64
    u0 = one(T)
    u1 = -evalpoly(p2, (0.125, -0.20833333333333334))
    u2 = evalpoly(p2, (0.0703125, -0.4010416666666667, 0.3342013888888889))
    u3 = -evalpoly(p2, (0.0732421875, -0.8912109375, 1.8464626736111112, -1.0258125964506173))
    u4 = evalpoly(p2, (0.112152099609375, -2.3640869140625, 8.78912353515625, -11.207002616222994, 4.669584423426247))
    u5 = -evalpoly(p2, (0.22710800170898438, -7.368794359479632, 42.53499874538846, -91.81824154324002, 84.63621767460073, -28.212072558200244))
    u6 = evalpoly(p2, (0.5725014209747314, -26.491430486951554, 218.1905117442116, -699.5796273761325, 1059.9904525279999, -765.2524681411817, 212.57013003921713))
    u7 = -evalpoly(p2, (1.7277275025844574, -108.09091978839466, 1200.9029132163525, -5305.646978613403, 11655.393336864534, -13586.550006434136, 8061.722181737309, -1919.457662318407))
    u8 = evalpoly(p2, (6.074042001273483, -493.91530477308805, 7109.514302489364, -41192.65496889755, 122200.46498301747, -203400.17728041555, 192547.00123253153, -96980.59838863752, 20204.29133096615))
    u9 = -evalpoly(p2, (24.380529699556064, -2499.8304818112097, 45218.76898136273, -331645.17248456355, 1.2683652733216248e6, -2.8135632265865337e6, 3.763271297656404e6, -2.998015918538107e6, 1.3117636146629772e6, -242919.18790055133))
    u10 = evalpoly(p2, (110.01714026924674, -13886.08975371704, 308186.40461266245, -2.7856181280864547e6, 1.3288767166421818e7, -3.7567176660763346e7, 6.634451227472903e7, -7.410514821153265e7, 5.095260249266464e7, -1.9706819118432228e7, 3.284469853072038e6))
    u11 = -evalpoly(p2, (551.3358961220206, -84005.4336030241, 2.2437681779224495e6, -2.4474062725738727e7, 1.420629077975331e8, -4.9588978427503026e8, 1.1068428168230145e9, -1.6210805521083372e9, 1.5535968995705802e9, -9.394623596815784e8, 3.2557307418576574e8, -4.932925366450996e7))
    u12 = evalpoly(p2, (3038.090510922384, -549842.3275722887, 1.7395107553978164e7, -2.2510566188941526e8, 1.5592798648792574e9, -6.563293792619285e9, 1.79542137311556e10, -3.3026599749800724e10, 4.1280185579753975e10, -3.4632043388158775e10, 1.8688207509295826e10, -5.866481492051847e9, 8.147890961183121e8))
    u13 = -evalpoly(p2, (18257.755474293175, -3.8718334425726123e6, 1.43157876718889e8, -2.167164983223795e9, 1.763473060683497e10, -8.786707217802327e10, 2.879006499061506e11, -6.453648692453765e11, 1.0081581068653821e12, -1.0983751560812233e12, 8.192186695485773e11, -3.990961752244665e11, 1.144982377320258e11, -1.4679261247695616e10))
    u14 = evalpoly(p2, (118838.42625678326, -2.9188388122220814e7, 1.2470092935127103e9, -2.1822927757529224e10, 2.0591450323241e11, -1.1965528801961816e12, 4.612725780849132e12, -1.2320491305598287e13, 2.334836404458184e13, -3.166708858478516e13, 3.056512551993532e13, -2.0516899410934438e13, 9.109341185239898e12, -2.406297900028504e12, 2.86464035717679e11))   
    u15 = -evalpoly(p2, (832859.3040162893, -2.3455796352225152e8, 1.1465754899448236e10, -2.2961937296824646e11, 2.4850009280340854e12, -1.663482472489248e13, 7.437312290867914e13, -2.3260483118893994e14, 5.230548825784446e14, -8.57461032982895e14, 1.0269551960827625e15, -8.894969398810265e14, 5.4273966498765975e14, -2.213496387025252e14, 5.417751075510605e13, -6.019723417234006e12))
    u16 = evalpoly(p2, (6.252951493434797e6, -2.0016469281917763e9, 1.1099740513917902e11, -2.5215584749128545e12, 3.100743647289646e13, -2.3665253045164925e14, 1.2126758042503475e15, -4.3793258383640155e15, 1.1486706978449752e16, -2.2268225133911144e16, 3.213827526858624e16, -3.4447226006485144e16, 2.705471130619708e16, -1.5129826322457682e16, 5.705782159023671e15, -1.3010127235496995e15, 1.3552215870309369e14))
    u17 = -evalpoly(p2, (5.0069589531988926e7, -1.8078220384658062e10, 1.128709145410874e12, -2.886383763141476e13, 4.0004445704303625e14, -3.4503855118462725e15, 2.0064271476309532e16, -8.270945651585064e16, 2.4960365126160426e17, -5.62631788074636e17, 9.575335098169139e17, -1.2336116931960694e18, 1.1961991142756308e18, -8.592577980317548e17, 4.4347954614171904e17, -1.5552983504313904e17, 3.3192764720355224e16, -3.254192619642669e15))
    u18 = evalpoly(p2, (4.259392165047669e8, -1.722832387173505e11, 1.2030115826419191e13, -3.4396530474307594e14, 5.335106978708839e15, -5.1605093193485224e16, 3.37667624979061e17, -1.5736434765189599e18, 5.402894876715982e18, -1.3970803516443374e19, 2.757282981650519e19, -4.178861444656839e19, 4.859942729324836e19, -4.301555703831444e19, 2.846521225167657e19, -1.3639420410571592e19, 4.47020096401231e18, -8.966114215270463e17, 8.30195760673191e16))
    u19 = -evalpoly(p2, (3.8362551802304335e9, -1.7277040123529995e12, 1.3412416915180639e14, -4.2619355104268985e15, 7.351663610930971e16, -7.921651119323832e17, 5.789887667664653e18, -3.025566598990372e19, 1.1707490535797259e20, -3.434621399768417e20, 7.756704953461136e20, -1.360203777284994e21, 1.8571089321463453e21, -1.9677247077053125e21, 1.6016898573693598e21, -9.824438427689858e20, 4.392792200888712e20, -1.351217503435996e20, 2.5563802960529236e19, -2.242438856186775e18))
    u20 = evalpoly(p2, (3.646840080706556e10, -1.818726203851104e13, 1.5613123930484672e15, -5.48403360388329e16, 1.0461721131134344e18, -1.2483700995047234e19, 1.0126774169536592e20, -5.8917941350694964e20, 2.548961114664972e21, -8.405915817108351e21, 2.1487414815055883e22, -4.302534303482379e22, 6.783661642951883e22, -8.423222750084323e22, 8.19433100543513e22, -6.173206302884415e22, 3.528435843903409e22, -1.4787743528433614e22, 4.285296082829494e21, -7.671943936729004e20, 6.393286613940837e19))
    u21 = -evalpoly(p2, (3.6490108188498334e11, -2.0052440123627112e14, 1.894406984252143e16, -7.319501491566134e17, 1.5365025218443373e19, -2.0197335419300872e20, 1.8081594057131945e21, -1.1640246461465369e22, 5.591591380366263e22, -2.0566149136271542e23, 5.8965434619782445e23, -1.3337178907798302e24, 2.3967237744351682e24, -3.430872898515746e24, 3.905264103536985e24, -3.511096528332644e24, 2.461506085403875e24, -1.3170969618092387e24, 5.194289094766812e23, -1.4228394823321413e23, 2.417461500896379e22, -1.91862023880665e21))
    u22 = evalpoly(p2, (3.8335346613939443e12, -2.3109159761323565e15, 2.3920280120269997e17, -1.0121818379942089e19, 2.3275346258089414e20, -3.3544689122226785e21, 3.297557757461478e22, -2.336107524486965e23, 1.238524103792452e24, -5.0463598652544e24, 1.6103128541137314e25, -4.077501349206541e25, 8.26258535798955e25, -1.3459193994556415e26, 1.7635713272326644e26, -1.8526731041549917e26, 1.548092083577385e26, -1.0148048982766395e26, 5.103920268388802e25, -1.9006807535664433e25, 4.936185283790662e24, -7.980021228256559e23, 6.04547062746709e22))
    u23 = -evalpoly(p2, (4.218971570284097e13, -2.778481101311081e16, 3.1385283211499996e18, -1.4486387749510863e20, 3.6341499869780876e21, -5.7179919065432055e22, 6.144339925144987e23, -4.766924608251481e24, 2.774466490672939e25, -1.2449342046124282e26, 4.392130563430048e26, -1.2355529146787609e27, 2.7982068996977173e27, -5.131998439010333e27, 7.641216535678268e27, -9.228395023257356e27, 8.999255845917453e27, -7.02322235515725e27, 4.322773732100187e27, -2.050902994929233e27, 7.234243234844319e26, -1.7860680966743495e26, 2.753863007576946e25, -1.9955529040412654e24))
    u24 = evalpoly(p2, (4.8540146868529006e14, -3.4792991439250445e17, 4.273207395701127e19, -2.1435653415108537e21, 5.844687629283339e22, -1.0000750138961727e24, 1.1699189691874474e25, -9.896648661695488e25, 6.29370256208713e26, -3.0939194683063286e27, 1.1998211967644424e28, -3.7252346341093444e28, 9.358117764887965e28, -1.9153963148099324e29, 3.206650343980748e29, -4.395132918078325e29, 4.9215508698387624e29, -4.4775348387950634e29, 3.277658265637452e29, -1.9012207767547338e29, 8.536184882279286e28, -2.8599776383548e28, 6.728957650918171e27, -9.916401268407057e26, 6.886389769727123e25))
    u25 = -evalpoly(p2, (5.827244631566907e15, -4.5305357275125955e18, 6.029638127487473e20, -3.2761234100445222e22, 9.675654883193622e23, -1.7941040647617987e25, 2.2764310713849358e26, -2.0914533474677945e27, 1.4471195817119858e28, -7.757785573404132e28, 3.2900927159291354e29, -1.1210232552135908e30, 3.1034661143911036e30, -7.036055338636485e30, 1.3128796688902614e31, -2.0208792587851872e31, 2.5653099826522344e31, -2.6771355605594045e31, 2.2823085118856488e31, -1.5730388076301427e31, 8.627355824571355e30, -3.676221426681414e30, 1.1728484268744769e30, -2.6355294419807464e29, 3.7195112743738626e28, -2.479674182915908e27))

    return evalpoly(-p/v, (u0, u1, u2, u3, u4, u5, u6, u7, u8, u9, u10, u11, u12, u13, u14, u15, u16,  u17, u18, u19, u20, u21))
end
=#
