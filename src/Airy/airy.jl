#######
####### Real arguments
#######

# airyai & airyaix

function airyai(x::Float64)
    if x >= 2.06
        return exp(-2/3 * x * sqrt(x)) * airyaix_large_pos_arg(x)[1]
    else
        if x <= -9.8
            if x >= -1e8
                return airyai_large_neg_arg(x)[1]
            else
                isinf(x) && return 0.0
                throw(DomainError(x, "Total loss of significant digits for large negative arguments. Requires a higher precision routine."))
            end
        else
            return airyai_small_arg(x)
        end
    end
end

function airyaix(x::Float64)
    if x >= 2.06
        return airyaix_large_pos_arg(x)[1]
    elseif x >= 0.0
        # taylor expansion at x = 1.5 
        b = evalpoly(x - 1.5, (0.07174949700810541, -0.09738201284230132, 0.05381212275607906, -0.012387253709224428, -0.0013886523923485612, 0.0017615621096121207, -0.00048234107659157565, 2.9849780287371904e-5, 1.853661597722781e-5, -6.0773111966738585e-6, 6.406078250357068e-7, 8.5642265292882e-8, -3.876060196303256e-8, 4.929943737019422e-9, 1.5110638652930308e-10, -1.493604112262068e-10, 2.148584715338907e-11, -2.6814055261032026e-13, -3.827831388762196e-13, 6.164805942828536e-14, -2.2166191076964464e-15, -6.912167850804561e-16, 1.2624054278515299e-16, -6.42973178916429e-18, -9.091593675774033e-19, 1.9432657516901093e-19, -1.198995513927753e-20, -8.798710894927164e-22, 2.33256140820231e-22, -1.6391332233394835e-23, -6.091803198418045e-25))
        return exp(2/3 * x * sqrt(x)) * b
    else
        isnan(x) && return x
        # negative numbers return complex arguments
        throw(DomainError(x, "Complex result returned for real arguments. Use complex argument: airyaix(complex(x))"))
    end
end

# airyaiprime & airyaiprimex

function airyaiprime(x::Float64)
    if x >= 2.06
        isinf(x) && return 0.0
        return exp(-2/3 * x * sqrt(x)) * airyaix_large_pos_arg(x)[2]
    else
        if x <= -9.5
            if x >= -1e8
                return airyai_large_neg_arg(x)[2]
            else
                throw(DomainError(x, "Total loss of significant digits for large negative arguments. Requires a higher precision routine."))
            end
        else
            return airyaiprime_small_arg(x)
        end
    end
end

function airyaiprimex(x::Float64)
    if x >= 2.06
        return airyaix_large_pos_arg(x)[2]
    elseif x >= 0.0
        # taylor expansion at x = 1.5
        b = evalpoly(x - 1.5, (-0.09738201284230132, 0.10762424551215811, -0.03716176112767328, -0.005554609569394245, 0.008807810548060603, -0.002894046459549454, 0.00020894846201160332, 0.00014829292781782247, -5.469580077006472e-5, 6.4060782503570685e-6, 9.42064918221702e-7, -4.651272235563907e-7, 6.408926858125249e-8, 2.1154894114102434e-9, -2.2404061683931022e-9, 3.437735544542251e-10, -4.558389394375444e-12, -6.8900964997719525e-12, 1.1713131291374217e-12, -4.4332382153928926e-14, -1.451555248668958e-14, 2.7772919412733657e-15, -1.4788383115077865e-16, -2.181982482185768e-17, 4.858164379225273e-18, -3.117388336212158e-19, -2.3756519416303343e-20, 6.531171942966468e-21, -4.753486347684502e-22, -1.8275409595254135e-23, 6.955638082337959e-24, -5.582291197792755e-25, -8.519287088295366e-27, 6.00631612185601e-27))
        return exp(2/3 * x * sqrt(x)) * b
    else
        isnan(x) && return x
        # negative numbers return complex arguments
        throw(DomainError(x, "Complex result returned for real arguments. Use complex argument: airyaix(complex(x))"))
    end
end

# asymptotic expansions for airyai
# positive arguments are asymptotically scaled
# negative arguments are not

function airyaix_large_pos_arg(x::T) where T <: Float64
    if x > 1000.0
        invx3 = 1 / (x * x * x)
        p = evalpoly(invx3, (1.5707963267948966, 0.13124057851910487, 0.4584353787485384))
        q = evalpoly(invx3, (0.1636246173744684, 0.20141783231057064, 1.3848568733028765))
        p1 = evalpoly(invx3, (-1.5707963267948966, 0.15510250188621483, 0.4982993247266722))
        q1 = evalpoly(invx3, (0.22907446432425577, 0.22511404787652015, 1.4803642438754887))

        xsqr = sqrt(x)
        xsqrx = 1 / (x * xsqr)
        a = muladd(xsqrx, -q, p)
        c = muladd(xsqrx, -q1, p1)
        xsqr = sqrt(xsqr)
        ai = a / (PIPOW3O2(T) * xsqr)
        aip = c * xsqr * inv(PIPOW3O2(T))
        return ai, aip
    else
        xsqr = sqrt(x)
        zinv = 3 / (2 * x * xsqr)
        xsqr = sqrt(xsqr)
        p = evalpoly(zinv, (9.99999999999999995305e-1, 1.40264691163389668864e1, 7.05360906840444183113e1, 1.59756391350164413639e2, 1.68089224934630576269e2, 7.62796053615234516538e1, 1.20075952739645805542e1, 3.46538101525629032477e-1))
        q = evalpoly(zinv, (1.00000000000000000470e0, 1.40959135607834029598e1, 7.14778400825575695274e1, 1.64234692871529701831e2, 1.77318088145400459522e2, 8.45138970141474626562e1, 1.47562562584847203173e1, 5.67594532638770212846e-1))
        p1 = evalpoly(zinv, (1.00000000000000000550e0, 1.39470856980481566958e1, 6.99778599330103016170e1, 1.59317847137141783523e2, 1.71184781360976385540e2, 8.20584123476060982430e1, 1.47454670787755323881e1, 6.13759184814035759225e-1))
        q1 = evalpoly(zinv, (9.99999999999999994502e-1, 1.38498634758259442477e1, 6.86752304592780337944e1, 1.53206427475809220834e2, 1.58778084372838313640e2, 7.11727352147859965283e1, 1.11810297306158156705e1, 3.34203677749736953049e-1))
        ai = (ONEOSQPI(T)/2) * p / (q * xsqr)
        aip = -(ONEOSQPI(T)/2)* xsqr * p1 / q1
        return ai, aip
    end
end

function airyai_large_neg_arg(x::T) where T <: Float64
    invx3 = 1 / x^3
    p = evalpoly(invx3, (1.5707963267948966, 0.13124057851910487, 0.4584353787485384, 5.217255928936184, 123.97197893818594, 5038.313653002081, 312467.7049060495, 2.746439545069411e7, 3.2482560591146026e9, 4.97462635569055e11, 9.57732308323407e13))
    q = evalpoly(invx3, (0.1636246173744684, 0.20141783231057064, 1.3848568733028765, 23.555289417250567, 745.2667344964557, 37835.063701047824, 2.8147130917899106e6, 2.8856687720069575e8, 3.8998976239149216e10, 6.718472897263214e12, 1.4370735281142392e15))
    p1 = evalpoly(invx3, (-1.5707963267948966, 0.15510250188621483, 0.4982993247266722, 5.515384839161109, 129.24738229725767, 5209.103946324185, 321269.61208650155, 2.812618811215662e7, 3.3166403972012258e9, 5.0676100258903735e11, 9.738286496397669e13))
    q1 = evalpoly(invx3, (0.22907446432425577, 0.22511404787652015, 1.4803642438754887, 24.70432792540913, 773.390007496322, 38999.21950723391, 2.8878225227454924e6, 2.950515261265541e8, 3.97712331943799e10, 6.837383921993536e12, 1.460066704564067e15))

    xabs = abs(x)
    xsqr = sqrt(xabs)
    xsqrx = xabs * xsqr
    z = -2 * xsqrx / 3

    # spc = sin(z) + cos(z) = sqrt(2) * sin(z + pi/4)
    # smc = sin(z) - cos(z) = -sqrt(2) * cos(z + pi/4)
    # prone to error for large arguments
    spc, smc = sincos(mod2pi(z) + π/4)
    a = -p * smc + q / xsqrx * spc
    c = p1 * spc + q1 / xsqrx * smc

    xsqr = sqrt(xsqr)
    ai = -2 * a / (xsqr * PIPOW3O2(T))
    aip = (2/PIPOW3O2(T)) * xsqr * c
    return ai, aip
end

# taylor expansions around zeros for small arguments

function airyai_small_arg(x::T) where T <: Float64
    if x >= 0.0
        # taylor expansion at x = 1.5 
        p = evalpoly(x - 1.5, (0.07174949700810541, -0.09738201284230132, 0.05381212275607906, -0.012387253709224428, -0.0013886523923485612, 0.0017615621096121207, -0.00048234107659157565, 2.9849780287371904e-5, 1.853661597722781e-5, -6.0773111966738585e-6, 6.406078250357068e-7, 8.5642265292882e-8, -3.876060196303256e-8, 4.929943737019422e-9, 1.5110638652930308e-10, -1.493604112262068e-10, 2.148584715338907e-11, -2.6814055261032026e-13, -3.827831388762196e-13, 6.164805942828536e-14, -2.2166191076964464e-15, -6.912167850804561e-16, 1.2624054278515299e-16, -6.42973178916429e-18, -9.091593675774033e-19, 1.9432657516901093e-19, -1.198995513927753e-20, -8.798710894927164e-22, 2.33256140820231e-22, -1.6391332233394835e-23, -6.091803198418045e-25))
    elseif x > -1.0
        p = evalpoly(x + 0.5, (0.4757280916105396, -0.20408167033954738, -0.1189320229026349, 0.09629482113005221, -0.012051304907352494, -0.00835397167338305, 0.0034106824527909488, -0.00018748378739668977, -0.00017963058749604507, 4.867256036790685e-5, -1.0852054849851912e-6, -1.85424425163635e-6, 3.728421447757534e-7, -1.0133548664552323e-9, -1.1212446835297949e-8, 1.777851534328481e-9, 1.9136952296640593e-11, -4.449034045022864e-11, 5.778702804510329e-12, 1.2100035825074537e-13, -1.2468339961179948e-13, 1.3614768155678468e-14, 3.9684428150788985e-16, -2.598632088728038e-16, 2.430497466471834e-17, 8.779598099071528e-19, -4.184856864694815e-19))
    elseif x > -3.2
        p = evalpoly(x + 2.338107410459767, (2.743319340666283e-17, 0.7012108227206914, -3.207087639834719e-17, -0.2732510368163064, 0.058434235226724286, 0.03194451370480103, -0.01366255184081532, -0.0003870349759524901, 0.0011408754894571796, -0.00017718920132546787, -3.3939160136269284e-5, 1.4137844310270033e-5, -7.41180299288454e-7, -4.2945486337203914e-7, 8.72022168160613e-8, 1.252053805808083e-9, -2.6389292196591304e-9, 3.0983375196473186e-10, 2.4255404477032373e-11, -9.8343678688258e-12, 6.661105552981143e-13, 1.1249812587695572e-13, -2.4657588515917296e-14, 7.965965484631788e-16, 3.0824314548929273e-16, -4.420019468170955e-17, 1.167553319557466e-19, 5.863076185446756e-19, -5.882695924413488e-20))
    elseif x > -4.75
        p = evalpoly(x + 4.08794944413097, (-2.720348378642871e-16, -0.803111369654864, 5.560323321157856e-16, 0.5471797795259772, -0.06692594747123885, -0.11184216377764623, 0.027358988976298886, 0.009292361042237976, -0.003994362992058797, -0.00014760712751364074, 0.00028467905572535616, -3.082684106536036e-5, -9.934550872135151e-6, 2.6326770738641654e-6, 5.3764289286128445e-8, -9.855619834673579e-8, 1.0053714072345167e-8, 1.6788861968137084e-9, -4.5638978170010107e-10, 9.328982974624003e-12, 9.327854082162345e-12, -1.1774433153941012e-12, -6.234375094261117e-14, 2.7947001637990885e-14, -1.6713500242449534e-15, -2.9431613458960554e-16))
    elseif x > -6.1
        p = evalpoly(x + 5.520559828095551, (2.313678943005095e-16, 0.8652040258941519, -6.386401513932251e-16, -0.7960684314096329, 0.07210033549117963, 0.21973717014275287, -0.0398034215704817, -0.027165996636626166, 0.007847756076526893, 0.0015301123354424383, -0.0007832222619265922, -5.448369227182677e-6, 4.434801281139783e-5, -4.82784752334856e-6, -1.3751331165365516e-6, 3.3809730430936423e-7, 1.1515237992029015e-8, -1.1917718796669944e-8, 8.97146222351664e-10, 2.2604595796334607e-10, -4.439596892555847e-11, -8.351286011527614e-13, 1.0197761050717805e-12, -7.862765122280811e-14, -1.1711709421130035e-14, 2.423074596316538e-15))
    elseif x > -7.2
        p = evalpoly(x + 6.786708090071759, (-8.710477837103708e-17, -0.9108507370496018, 2.9557735202731247e-16, 1.0302796776637262, -0.07590422808746698, -0.3496103711718467, 0.05151398388318634, 0.05468569776946418, -0.012486084684708815, -0.004439192827500768, 0.0015491678856944288, 0.00016037655628253796, -0.00011327987159259477, 2.9534552161146124e-6, 5.10535152341918e-6, -6.348767142926879e-7, -1.3206281362722718e-7, 3.461056785480714e-8, 8.542321939505024e-10, -1.0729667675129367e-9, 7.582406135085136e-11, 1.9371772465258795e-11, -3.436282550010513e-12, -1.0997332719001945e-13, 7.734206349128181e-14, -4.483209467796499e-15))
    elseif x > -8.5
        p = evalpoly(x + 7.944133587120853, (-3.222967925030853e-17, 0.9473357094415678, 1.28018438717254e-16, -1.25429357127562, 0.0789446424534639, 0.49821378438402086, -0.06271467856378098, -0.09235552894376721, 0.017793349442286454, 0.00931902751214878, -0.0025967585986179237, -0.0005112568183297996, 0.00022687897509904778, 9.389319637951164e-6, -1.2712163212229125e-5, 7.25185550490412e-7, 4.5990184323826115e-7, -6.791593419402475e-8, -9.56972591227924e-9, 2.922324845525447e-9, 2.1334860119088188e-11, -7.805967826213263e-11, 5.9585235209456126e-12, 1.2676904585002835e-12, -2.2716482806979397e-13, -6.8536313808318734e-15))
    else
        p = evalpoly(x + 9.02265085334098, (2.1834671977219237e-16, -0.9779228085694986, -9.850331087383878e-16, 1.4705760105401993, -0.0814935673807908, -0.6634246948201652, 0.07352880052700973, 0.14057990051109173, -0.02369373910072015, -0.016595479983083087, 0.00393733595363381, 0.0011458316593658873, -0.0003948536938259645, -4.103271183031362e-5, 2.587065207093167e-5, -1.1728505435852704e-7, -1.1435607200608036e-6, 9.900321384824919e-8, 3.3335503439036955e-8, -5.955649567170201e-9, -5.309773544803389e-10, 2.0731250021063097e-10, -2.5212690187520218e-12, -4.7460190937036376e-12, 4.1677722875756535e-13, 6.716734034504283e-14))
    end
    return p
end

function airyaiprime_small_arg(x::T) where T <: Float64
    if x > 0.1
        p = evalpoly(x - 1.5, (-0.09738201284230132, 0.10762424551215811, -0.03716176112767328, -0.005554609569394245, 0.008807810548060603, -0.002894046459549454, 0.00020894846201160332, 0.00014829292781782247, -5.469580077006472e-5, 6.4060782503570685e-6, 9.42064918221702e-7, -4.651272235563907e-7, 6.408926858125249e-8, 2.1154894114102434e-9, -2.2404061683931022e-9, 3.437735544542251e-10, -4.558389394375444e-12, -6.8900964997719525e-12, 1.1713131291374217e-12, -4.4332382153928926e-14, -1.451555248668958e-14, 2.7772919412733657e-15, -1.4788383115077865e-16, -2.181982482185768e-17, 4.858164379225273e-18, -3.117388336212158e-19, -2.3756519416303343e-20, 6.531171942966468e-21))
    elseif x > -2.1
        p = evalpoly(x + 1.018792971647471, (-1.1246873724687218e-17, -0.5457232363649821, 0.26782832800784995, 0.09266316627889255, -0.09095387272749701, 0.013134992740413161, 0.006949737470916942, -0.002917297275227855, 0.00014721097333898997, 0.0001515927648587197, -3.813263266242759e-5, 8.296458876147209e-8, 1.55758560220824e-6, -2.672035857158013e-7, -8.22515911965634e-9, 9.283928640130678e-9, -1.1579575909261867e-9, -6.7029059958855e-11, 3.609115436353033e-11, -3.38533335716781e-12, -2.829534500722224e-13, 9.866581579686296e-14, -7.069976274435534e-15, -7.844811532823979e-16, 1.9991570243463872e-16, -1.0963571103138449e-17, -1.5705239700998077e-18, 3.120825352080613e-19))
    elseif x > -4.03
        p = evalpoly(x + 3.2481975821798366, (-3.315151654629452e-17, 1.3610450626413026, -0.20950773901628192, -0.7368238802848806, 0.22684084377355043, 0.10570029472060026, -0.055261791021366045, -0.0016934864099735572, 0.005407468330176707, -0.0008007715851877276, -0.00021632997518904743, 7.826693155932615e-5, -1.3497442526091854e-6, -3.142453810419922e-6, 4.899638015045217e-7, 4.168447683589849e-8, -2.0660058467837985e-8, 1.4236346987697045e-9, 3.6404479934989394e-10, -7.748421874625937e-11, 8.427265218804001e-13, 1.511640723657024e-12, -1.8202548037745256e-13, -7.958994836861e-15, 3.934069548729346e-15, -2.7347873985422944e-16, -3.2414238181600296e-17, 7.093654290955294e-18))
    elseif x > -5.5
        p = evalpoly(x + 4.820099211178736, (1.9002007513487082e-16, -1.8335969193618502, 0.19020323431407618, 1.473019844105969, -0.30559948656030816, -0.34232487381035187, 0.11047648830794765, 0.030555249293994464, -0.016640833099863316, -0.00029195123942834367, 0.001273168021708355, -0.00015529618742302247, -4.892380712504251e-5, 1.370162563867412e-5, 3.713190536062472e-7, -5.653827230320543e-7, 5.3710493778794144e-8, 1.1475273803238557e-8, -2.8091799082246527e-9, 4.555486497839958e-12, 6.750872335321682e-11, -7.0928318552774136e-12, -6.939729077051773e-13, 2.073351337864048e-13, -7.373577967817808e-15, -2.872535929393802e-15, 3.869468846775618e-16, 8.799696696329233e-18))
    elseif x > -6.8
        p = evalpoly(x + 6.163307355639486, (3.3524788679156663e-16, 2.205896662123774, -0.17895397185614714, -2.2659365205746744, 0.3676494436872962, 0.6863528964430919, -0.1699452390431007, -0.09021486959017666, 0.0330030319232237, 0.005024983874975287, -0.0033877728633306464, 5.181377628766877e-5, 0.00020005581568389722, -2.573779771192161e-5, -6.466340051454468e-6, 1.7813080120881245e-6, 5.115762237080756e-8, -6.572124324183966e-8, 5.154704616302637e-9, 1.3427693455239035e-9, -2.661643481572335e-10, -6.78546505935419e-12, 6.6025118995813095e-12, -4.684148897527137e-13, -8.657102435817311e-14, 1.6294270949749456e-14, 7.020254520958461e-17))
    elseif x > -7.9
        p = evalpoly(x + 7.37217725504777, (1.0028785856694853e-16, -2.523505448425921, 0.17115062220581154, 3.1006215783124498, -0.42058424140431994, -1.1315065523268806, 0.23254661837343366, 0.18659442331706105, -0.05418689050759992, -0.01541443888390889, 0.006771045421706508, 0.00048573017836110537, -0.000506615377447726, 2.439555149034597e-5, 2.3412450856604934e-5, -3.454448194852507e-6, -6.10261028364471e-7, 1.854414901637662e-7, 2.707847274247799e-9, -5.88674348492048e-9, 4.6258175023029366e-10, 1.1011543328016952e-10, -2.076042276366767e-11, -6.466028459201257e-13, 4.858155738241608e-13, -2.8160298411012274e-14, -6.546251007171164e-15))
    elseif x > -9.0
        p = evalpoly(x + 8.488486734019721, (1.9865763636596917e-15, 2.8052430870313785, -0.16523811457399187, -3.968711454994397, 0.4675405145052357, 1.6734018525386696, -0.29765335912458146, -0.3248476382988628, 0.07998087056358093, 0.033573466676480326, -0.011604112798228065, -0.001782911750352928, 0.0010260012946360286, 1.586660639280247e-5, -5.84653082865604e-5, 4.620195206034647e-6, 2.1386747050487544e-6, -3.734612544877612e-7, -4.32848184829349e-8, 1.5890643286120207e-8, -7.049077495383936e-11, -4.296440036986022e-10, 3.7410249910157256e-11, 7.061620449058568e-12, -1.389003055566532e-12, -3.4842814979282226e-14, 2.945598253096211e-14))
    else
        p = evalpoly(x + 9.535449052433547123541757173, (-1.0626912677608902e-15, -3.0610916737763576, 0.16051114409736328, 4.864813950020498, -0.510181945629397, -2.3087085355595987, 0.36486104625153865, 0.5095798638807557, -0.11022512873634545, -0.061695677462806485, 0.01804803829143557, 0.004234760217630525, -0.001817889354798794, -0.00013263827730311434, 0.00012045081443999045, -3.2998164849963075e-6, -5.377771018267827e-6, 5.880371349671046e-7, 1.5612224361123518e-7, -3.304476207996624e-8, -2.2841837768922437e-9, 1.1415139263443008e-9, -2.7957320677518033e-11, -2.624071604789366e-11, 2.644903133984302e-12, 3.6840692435819356e-13, -8.085295122966928e-14))
    end
    return p
end

### airybi

function airybi(x::Float64)
    if x >= 4.0
        c = exp(x * sqrt(x) / 3)
        if x > 10.0
            return  (c * airybix_large_pos_arg(x)[1]) * c
        else
            # taylor expansion
            bi = evalpoly(x - 7.0, (0.5675133598800484, -0.0007477354338554879, 0.00014194446383006344, -2.5467738873064998e-5, 4.4658245894850016e-6, -7.7733130696664e-7, 1.3564658558983838e-7, -2.3927894309084685e-8, 4.3007485171860115e-9, -7.92892247354981e-10, 1.5018964443699618e-10, -2.898176382710382e-11, 5.572364693338984e-12, -1.029468593963962e-12, 1.7320419193628474e-13, -2.409757552986111e-14, 2.0102744342122725e-15, 2.135228358804251e-16, -1.4989219572628205e-16, 4.295496099668265e-17, -8.905565690230879e-18, 1.4198157070634278e-18, -1.6086384378830022e-19, 6.6966278416098094e-21, 2.3524616627520386e-21, -7.841001901743284e-22, 1.4372073571402632e-22, -1.764840969406179e-23, 1.0978182859053242e-24, 1.1282777095151025e-25, -4.741249452379852e-26, 8.232684039675075e-27, -8.807294952286965e-28, 3.6417337825780214e-29, 7.767720965864765e-30, -2.1432412848595527e-30, 2.8951939613862145e-31, -2.1346403264300826e-32, -4.254468872360338e-34, 3.9050657842432525e-34, -6.341097414084598e-35, 5.664889941820633e-36))
            return (bi * c) * c / sqrt(sqrt(x))
        end
    elseif x > -10.0
        return airybi_small_arg(x)
    else
        if x >= -1e8
            return airybi_large_neg_arg(x)[1]
        else
            isinf(x) && return 0.0
            throw(DomainError(x, "Total loss of significant digits for large negative arguments. Requires a higher precision routine."))
        end
    end
end

function airybix(x::Float64)
    if x >= 4.0
        if x > 10.0
            return airybix_large_pos_arg(x)[1]
        else
            # taylor expansion
            bi = evalpoly(x - 7.0, (0.5675133598800484, -0.0007477354338554879, 0.00014194446383006344, -2.5467738873064998e-5, 4.4658245894850016e-6, -7.7733130696664e-7, 1.3564658558983838e-7, -2.3927894309084685e-8, 4.3007485171860115e-9, -7.92892247354981e-10, 1.5018964443699618e-10, -2.898176382710382e-11, 5.572364693338984e-12, -1.029468593963962e-12, 1.7320419193628474e-13, -2.409757552986111e-14, 2.0102744342122725e-15, 2.135228358804251e-16, -1.4989219572628205e-16, 4.295496099668265e-17, -8.905565690230879e-18, 1.4198157070634278e-18, -1.6086384378830022e-19, 6.6966278416098094e-21, 2.3524616627520386e-21, -7.841001901743284e-22, 1.4372073571402632e-22, -1.764840969406179e-23, 1.0978182859053242e-24, 1.1282777095151025e-25, -4.741249452379852e-26, 8.232684039675075e-27, -8.807294952286965e-28, 3.6417337825780214e-29, 7.767720965864765e-30, -2.1432412848595527e-30, 2.8951939613862145e-31, -2.1346403264300826e-32, -4.254468872360338e-34, 3.9050657842432525e-34, -6.341097414084598e-35, 5.664889941820633e-36))
            return bi / sqrt(sqrt(x))
        end
    elseif x >= -10.0
        x >= 0.0 ? (c = exp(-2 * x * sqrt(x) / 3)) : (c = 1.0)
        return airybi_small_arg(x) * c
    else
        if x >= -1e8
            return airybi_large_neg_arg(x)[1]
        else
            isnan(x) && return x
            isinf(x) && return 0.0
            throw(DomainError(x, "Total loss of significant digits for large negative arguments. Requires a higher precision routine."))
        end
    end
end

function airybiprime(x::Float64)
    if x >= 4.0
        c = exp(2 * sqrt(x)^3 / 3)
        if x > 10.0
            return  c * airybix_large_pos_arg(x)[2]
        else
            # taylor expansion
            bip = evalpoly(x - 7.0, (1.480483146234023, 0.10847769208242874, -0.004095041219645394, 0.00031722063160794314, -3.154331521824236e-5, 3.6175094805300984e-6, -4.5968504008374383e-7, 6.365989571811271e-8, -9.552944556807737e-9, 1.5496383095348153e-9, -2.6954321385057084e-10, 4.913178107697451e-11, -9.004103566986968e-12, 1.5633136265286318e-12, -2.3490289069613717e-13, 2.4389832689282358e-14, 5.963080034697866e-16, -1.1878114347826124e-15, 3.910018371588521e-16, -8.820137252280557e-17, 1.5103509411860735e-17, -1.8467065121344417e-18, 9.339941280298513e-20, 2.5720671252691455e-20, -9.536894871188102e-21, 1.8595980453826083e-21, -2.421650373808468e-22, 1.6545678071536236e-23, 1.4324467976358602e-24, -6.867391522840432e-25, 1.2587408257198288e-25, -1.4142087890958792e-26, 6.392354779834342e-28, 1.2539785636592336e-28, -3.685370834263758e-29, 5.196558115282775e-30, -4.032051381758382e-31, -6.151546747788048e-33, 7.357962994341929e-33, -1.2459482253456626e-33, 1.152470388945998e-34, -2.580556780035801e-36))
            return bip * c / sqrt(sqrt(x))
        end
    elseif x > -10.0
        return airybiprime_small_arg(x)
    else
        if x >= -1e8
            return airybi_large_neg_arg(x)[2]
        else
            isnan(x) && return x
            throw(DomainError(x, "Total loss of significant digits for large negative arguments. Requires a higher precision routine."))
        end
    end
end

function airybiprimex(x::Float64)
    if x >= 4.0
        if x > 10.0
            return airybix_large_pos_arg(x)[2]
        else
            # taylor expansion
            bip = evalpoly(x - 7.0, (1.480483146234023, 0.10847769208242874, -0.004095041219645394, 0.00031722063160794314, -3.154331521824236e-5, 3.6175094805300984e-6, -4.5968504008374383e-7, 6.365989571811271e-8, -9.552944556807737e-9, 1.5496383095348153e-9, -2.6954321385057084e-10, 4.913178107697451e-11, -9.004103566986968e-12, 1.5633136265286318e-12, -2.3490289069613717e-13, 2.4389832689282358e-14, 5.963080034697866e-16, -1.1878114347826124e-15, 3.910018371588521e-16, -8.820137252280557e-17, 1.5103509411860735e-17, -1.8467065121344417e-18, 9.339941280298513e-20, 2.5720671252691455e-20, -9.536894871188102e-21, 1.8595980453826083e-21, -2.421650373808468e-22, 1.6545678071536236e-23, 1.4324467976358602e-24, -6.867391522840432e-25, 1.2587408257198288e-25, -1.4142087890958792e-26, 6.392354779834342e-28, 1.2539785636592336e-28, -3.685370834263758e-29, 5.196558115282775e-30, -4.032051381758382e-31, -6.151546747788048e-33, 7.357962994341929e-33, -1.2459482253456626e-33, 1.152470388945998e-34, -2.580556780035801e-36))
            return bip / sqrt(sqrt(x))
        end
    elseif x >= -10.0
        x >= 0.0 ? (c = exp(-2 * x * sqrt(x) / 3)) : (c = 1.0)
        return airybiprime_small_arg(x) * c
    else
        if x >= -1e8
            return airybi_large_neg_arg(x)[2]
        else
            isnan(x) && return x
            throw(DomainError(x, "Total loss of significant digits for large negative arguments. Requires a higher precision routine."))
        end
    end
end

function airybix_large_pos_arg(x::T) where T <: Float64
    invx3 = 1 / x^3
    p = evalpoly(invx3, (1.5707963267948966, 0.13124057851910487, 0.4584353787485384, 5.217255928936184, 123.97197893818594, 5038.313653002081, 312467.7049060495, 2.746439545069411e7, 3.2482560591146026e9, 4.97462635569055e11, 9.57732308323407e13, 2.2640712393216476e16))
    p1 = evalpoly(invx3, (0.1636246173744684, 0.20141783231057064, 1.3848568733028765, 23.555289417250567, 745.2667344964557, 37835.063701047824, 2.8147130917899106e6, 2.8856687720069575e8, 3.8998976239149216e10, 6.718472897263214e12, 1.4370735281142392e1, 3.7367429394637446e17))
    q = evalpoly(invx3, (-1.5707963267948966, 0.15510250188621483, 0.4982993247266722, 5.515384839161109, 129.24738229725767, 5209.103946324185, 321269.61208650155, 2.812618811215662e7, 3.3166403972012258e9, 5.0676100258903735e11, 9.738286496397669e13, 2.298637212441062e16))
    q1 = evalpoly(invx3, (0.22907446432425577, 0.22511404787652015, 1.4803642438754887, 24.70432792540913, 773.390007496322, 38999.21950723391, 2.8878225227454924e6, 2.950515261265541e8, 3.97712331943799e10, 6.837383921993536e12, 1.460066704564067e15, 3.7912939312807334e17))
    
    xsqr = sqrt(x)
    xsqrx = 1 / (x * xsqr)
    xsqr = sqrt(xsqr)
    bi = muladd(xsqrx, p1, p) / (xsqr * PIPOW3O2(T))
    bip = xsqr * muladd(xsqrx, q1, q) / PIPOW3O2(T)
    return 2*bi, -2*bip
end

# scaled factor is exp(-|2/3 Re(z^(3/2))|)
# for negative arguments the scaled Bi versions are equivalent airybi = airybix
function airybi_large_neg_arg(x::T) where T <: Float64
    invx3 = 1 / x^3
    p = evalpoly(invx3, (1.5707963267948966, 0.13124057851910487, 0.4584353787485384, 5.217255928936184, 123.97197893818594, 5038.313653002081, 312467.7049060495, 2.746439545069411e7, 3.2482560591146026e9, 4.97462635569055e11, 9.57732308323407e13, 2.2640712393216476e16))
    p1 = evalpoly(invx3, (0.1636246173744684, 0.20141783231057064, 1.3848568733028765, 23.555289417250567, 745.2667344964557, 37835.063701047824, 2.8147130917899106e6, 2.8856687720069575e8, 3.8998976239149216e10, 6.718472897263214e12, 1.4370735281142392e1, 3.7367429394637446e17))
    q = evalpoly(invx3, (-1.5707963267948966, 0.15510250188621483, 0.4982993247266722, 5.515384839161109, 129.24738229725767, 5209.103946324185, 321269.61208650155, 2.812618811215662e7, 3.3166403972012258e9, 5.0676100258903735e11, 9.738286496397669e13, 2.298637212441062e16))
    q1 = evalpoly(invx3, (0.22907446432425577, 0.22511404787652015, 1.4803642438754887, 24.70432792540913, 773.390007496322, 38999.21950723391, 2.8878225227454924e6, 2.950515261265541e8, 3.97712331943799e10, 6.837383921993536e12, 1.460066704564067e15, 3.7912939312807334e17))
    
    xabs = abs(x)
    xsqr = sqrt(xabs)
    xsqrx = xabs * xsqr
    z = 2 * xsqrx / 3

    # spc = sin(z) + cos(z) = sqrt(2) * sin(z + pi/4)
    # smc = sin(z) - cos(z) = -sqrt(2) * cos(z + pi/4)
    # prone to error for large arguments
    spc, smc = sincos(mod2pi(z) + π/4)
    b = p1 * spc / xsqrx + p * smc
    d = q * spc - q1 * smc / xsqrx

    xsqr = sqrt(xsqr)
    bi = 2 * b / (xsqr * PIPOW3O2(T))
    bip = -(2 / PIPOW3O2(T)) * d * xsqr
    return bi, bip
end

function airybi_small_arg(x::T) where T <: Float64
    if x > -0.2
        # power series
        x3 = x*x*x
        a = evalpoly(x3, (0.6149266274460007, 0.10248777124100013, 0.0034162590413666706, 4.7448042241203764e-5, 3.5945486546366485e-7, 1.7116898355412612e-9, 5.5937576324877815e-12, 1.3318470553542337e-14, 2.412766404627235e-17, 3.4369891803806764e-20, 3.9505622762996283e-23, 3.7410627616473754e-26, 2.9690974298788695e-29, 2.0034395613217741e-32, 1.163437608200798e-35, 5.875947516165647e-39, 2.604586664967042e-42, 1.0214065352811929e-45, 3.568855818592568e-49, 1.1180625998097016e-52, 3.1583689260161066e-56, 8.08594195088609e-60, 1.884834953586501e-63))
        b = evalpoly(x3, (0.4482883573538264, 0.03735736311281886, 0.0008894610264956872, 9.882900294396524e-6, 6.335192496408029e-8, 2.6396635401700117e-10, 7.718314444941556e-13, 1.6706308322384318e-15, 2.7843847203973864e-18, 3.683048571954215e-21, 3.960267281671199e-24, 3.52964998366417e-27, 2.6498873751232507e-30, 1.698645753284135e-33, 9.405568955061657e-37, 4.5437531183872734e-40, 1.9318678224435686e-43, 7.284569466227635e-47, 2.4527169919958367e-50, 7.418986666654073e-54, 2.0270455373371784e-57, 5.0273946858560976e-61, 1.136905175453663e-64))
        p = muladd(x, b, a)
    elseif x > -2.2
        p = evalpoly(x + 1.173713222709128, (-6.5985241890579e-17, 0.6019578879762396, 3.8723875455316416e-17, -0.11775432210529542, 0.05016315733135329, 0.006910490244306752, -0.00588771610526477, 0.001001243418004953, 0.0002468032230109554, -9.809567700177314e-5, 7.906302352775167e-6, 3.2903583290776384e-6, -8.134500652724367e-7, 2.5925418426189934e-8, 2.3324810036821433e-8, -4.0184717699215364e-9, -6.046748046691523e-12, 1.030931745891974e-10, -1.3109067391453412e-11, -3.7148704746518476e-13, 3.117880534840298e-13, -3.017392412328179e-14, -1.5961835682297216e-15, 6.86173097250094e-16, -5.126895355684697e-17, -4.002590009232389e-18))
    elseif x > -4.05
        p = evalpoly(x + 3.271093302836353, (1.4912020792246877e-16, -0.7603101414928011, -2.43893056726376e-16, 0.4145075686526103, -0.06335917845773335, -0.06779464658972667, 0.020725378432630507, 0.0037715103802399754, -0.0024212373782045234, 0.00011650577897569078, 0.00012990670836290934, -2.5475805923214892e-5, -2.3365998844222516e-6, 1.366925939119848e-6, -9.79811521421597e-8, -3.241877223500228e-8, 7.030964290401067e-9, 2.9645869860049095e-11, -1.811036354176953e-10, 2.02748242223541e-11, 1.6369809441952335e-12, -5.891058979705288e-13, 3.229460350416958e-14, 7.043480833415071e-15, -1.2585952159615458e-15, 1.5424534202215543e-17))
    elseif x > -5.5
        p = evalpoly(x + 4.830737841662016, (1.9733757157816445e-16, 0.8369910126192611, -4.766430373021629e-16, -0.6738806929651456, 0.06974925105160529, 0.16276704821360755, -0.033694034648257314, -0.017060373526892724, 0.005813108864771701, 0.0006766688519582255, -0.0005015775388627367, 2.3129991230391897e-5, 2.3482260980834454e-5, -3.931490146004496e-6, -4.961904148214753e-7, 2.0225837715837952e-7, -6.393851385235093e-9, -5.4163515115941455e-9, 7.61913062088228e-10, 5.781030065954972e-11, -2.3939352033369288e-11, 1.1491587025101967e-12, 3.754437974718945e-13, -5.828189024438837e-14, -1.2038258285408947e-15, 1.0949805502650894e-15))
    elseif x > -6.7
        p = evalpoly(x + 6.169852128310251, (-2.4652322944876206e-16, -0.8894799014265397, 7.605059359461805e-16, 0.914659910484288, -0.07412332511887869, -0.28216581976907734, 0.045732995524214476, 0.03968566805999452, -0.010077350706038485, -0.002765579278043845, 0.0011317936862374988, 6.350785898737327e-5, -7.385287092336652e-5, 4.7433306878194e-6, 2.8525777573391674e-6, -4.910405707756589e-7, -5.3569384414458937e-8, 2.162582892656635e-8, -5.245927788687565e-10, -5.467764650394962e-10, 6.54276021046472e-11, 6.7831837087265114e-12, -2.057262110682013e-12, 4.6593600123797446e-14, 3.5282946957989075e-14, -3.907896222619103e-15))
    elseif x > -7.9
        p = evalpoly(x + 7.376762079367763, (3.9229436221051404e-16, 0.9299836385680267, -1.446931087552141e-15, -1.143378006570179, 0.07749863654733644, 0.42172137606250004, -0.05716890032850917, -0.07222475282022156, 0.015061477716517889, 0.006605776631491822, -0.00203699656109637, -0.0003060705894858609, 0.00016388042135750047, 1.415470237388889e-6, -8.32405201816858e-6, 7.306611151707449e-7, 2.6175008963208153e-7, -5.0418989799370194e-8, -3.922245164373553e-9, 1.8528625194856889e-9, -5.65408431706205e-11, -4.188183603904142e-11, 4.913313565632472e-12, 4.988369500720917e-13, -1.415329370181925e-13, 2.055853447588659e-15))
    elseif x > -9.0
        p = evalpoly(x + 8.491948846509388, (-2.5434712503223577e-16, -0.9632344301904238, 1.0799513875152367e-15, 1.3632895847289495, -0.08026953584920274, -0.5788492708248631, 0.06816447923644768, 0.11512592528178081, -0.020673188243745148, -0.01263165262727079, 0.0032297953593547093, 0.0007872196337628573, -0.0003034765879060938, -2.214893270209827e-5, 1.848531480425613e-5, -5.494713542623637e-7, -7.463553351311001e-7, 8.511543175468515e-8, 1.891679729735395e-8, -4.2957638235100794e-9, -1.987501137742938e-10, 1.3189572367449318e-10, -5.644995723162025e-12, -2.606327771326931e-12, 3.257839467288938e-13, 2.747967731363848e-14))
    else
        p = evalpoly(x + 9.538194379346239, (1.8020634719987473e-16, 0.9915863705176604, -8.59421583992181e-16, -1.576323924317981, 0.08263219754313905, 0.7517641997479385, -0.07881619621589926, -0.16875811588300885, 0.02684872141956927, 0.02126154883567329, -0.004720515995775305, -0.0015995278561913206, 0.000502172333137813, 6.753904879331083e-5, -3.5106292206536236e-5, -6.763249640425508e-7, 1.676623699155756e-6, -1.0535063689666924e-7, -5.447152845623752e-8, 7.840580561006179e-9, 1.0900247096289847e-9, -3.0775359498580484e-10, -5.5330887396656266e-12, 7.95541169870788e-12, -4.619165200519967e-13, -1.3568891981611074e-13))
    end
    return p
end

function airybiprime_small_arg(x::T) where T <: Float64
    if x > -1.5
        x3 = x*x*x
        ap = evalpoly(x3, (0.4482883573538264, 0.14942945245127545, 0.0062262271854698105, 9.882900294396525e-5, 8.235750245330437e-7, 4.223461664272019e-9, 1.4664797445388956e-11, 3.67538783092455e-14, 6.960961800993466e-17, 1.0312536001471802e-19, 1.2276828573180715e-22, 1.2000809944458178e-25, 9.804583287956028e-29, 6.79458301313654e-32, 4.0443946506765124e-35, 2.0901264344581458e-38, 9.466152329973487e-42, 3.78797612243837e-45, 1.3489943455977101e-48, 4.3030122666593625e-52, 1.236497777775679e-55, 3.2175325989479025e-59, 7.617264675539542e-63))
        bp = evalpoly(x3, (0.30746331372300034, 0.020497554248200024, 0.0004270323801708338, 4.313458385563978e-6, 2.567534753311892e-8, 1.0068763738478007e-10, 2.796878816243891e-13, 5.790639371105364e-16, 9.279870787027826e-19, 1.1851686828898885e-21, 1.2345507113436338e-24, 1.068875074756393e-27, 7.813414289154919e-31, 4.8864379544433515e-34, 2.6441763822745408e-37, 1.2502015991841802e-40, 5.209173329934083e-44, 1.9271821420399865e-47, 6.372956818915299e-51, 1.895021355609664e-54, 5.0941434290582364e-58, 1.2439910693670906e-61, 2.771816108215443e-65))
        p = muladd(x*x, bp, ap)
    elseif x > -3.2
        p = evalpoly(x + 2.294439682614123, (1.3050830085951108e-16, 1.0438424472052532, -0.22747219181982883, -0.39917225554412844, 0.17397374120087558, 0.030629020377963098, -0.029937919165809637, 0.0032974297534822746, 0.0018647251224384134, -0.0005802849783048269, -6.3210093935846245e-6, 3.093950621960744e-5, -4.725835616276457e-6, -4.992594707816475e-7, 2.4374144602236595e-7, -1.8780193767765568e-8, -4.559045448346791e-9, 1.1142680058276989e-9, -3.1024513355303083e-11, -2.1590191000016282e-11, 3.2825148908037815e-12, 4.0190496443783935e-14, -6.537063414339622e-14, 6.613854651768023e-15, 3.4783752581066423e-16))
    elseif x > -4.8
        p = evalpoly(x + 4.073155089071828, (-3.5706417820884903e-16, -1.615099007771363, 0.19826141804723305, 1.0964247904764644, -0.26918316796189407, -0.21007798288587065, 0.08223185928573487, 0.012682390560458464, -0.010357751717268665, 0.0005878045014194119, 0.0006272935388783455, -0.000126389381050211, -1.4458173626233763e-5, 7.68669086448864e-6, -4.287442087180428e-7, -2.2323535638602655e-7, 4.1592007781675354e-8, 1.661562764553658e-9, -1.3287524977803896e-9, 1.0897892878497395e-10, 1.885812317231568e-11, -4.387083138454629e-12, 8.141951267221141e-14, 7.435849614474649e-14, -8.909656360099548e-15))
    elseif x > -6.1
        p = evalpoly(x + 5.5123957296635995, (4.2827700216989146e-17, 2.0283916344286097, -0.18398458074347976, -1.8635495639516062, 0.3380652724047683, 0.5013654942009328, -0.13976621729637048, -0.05614396862733763, 0.02420309123708635, 0.00207992990472809, -0.002184210905396979, 0.0001402447897449079, 0.00010854664971815054, -2.0229873802934234e-5, -2.4528584220804398e-6, 1.0876736284147158e-6, -3.397391040630207e-8, -3.166202125524556e-8, 4.388662970046761e-9, 4.0514975156612263e-10, -1.516133406608186e-10, 5.6816654076685864e-12, 2.729783486500342e-12, -3.7579567525699357e-13, -1.6499499832774852e-14))
    elseif x > -7.4
        p = evalpoly(x + 6.781294445990305, (-7.721317833829156e-16, -2.370056419850032, 0.17474955841590484, 2.6786750727687814, -0.39500940330834017, -0.8965942491179204, 0.20090063045765894, 0.13347757899714746, -0.04300701702659608, -0.00938263950825763, 0.00490895024525397, 0.0001440078792007367, -0.0003303783370671734, 2.80683244741357e-5, 1.3167040208955681e-5, -2.600626800799143e-6, -2.4673488268918906e-7, 1.1647227562465254e-7, -3.5620394975059554e-9, -3.07333770503881e-9, 3.871005164858819e-10, 4.0694506307856404e-11, -1.2666768772243378e-11, 2.5607202530829446e-13, 2.3268359659136705e-13))
    elseif x > -8.5
        p = evalpoly(x + 7.940178689168579, (8.51891254034672e-16, 2.6681083909107306, -0.16801312006683342, -3.5308762309835418, 0.44468473181845736, 1.3905885354962473, -0.26481571732376624, -0.2501880899230309, 0.06651852511898834, 0.02338738341397691, -0.008995895297201397, -0.0010162775547694785, 0.0007360237718500377, -1.1181272935399847e-5, -3.816004186244733e-5, 4.197249000708146e-6, 1.2125733995252362e-6, -2.7217261662439e-7, -1.6890432688596642e-8, 1.0073100751030303e-8, -4.03105957534568e-10, -2.3276576844590606e-10, 2.982140502613569e-11, 2.817984811976686e-12, -8.698067306477899e-13))
    else
        p = evalpoly(x + 9.01958335879424, (1.4408236312418457e-15, -2.935962201853191, 0.1627548682163053, 4.413525969647323, -0.4893270336421936, -1.9795579449241065, 0.3310144477235477, 0.411133225177042, -0.09455529773724823, -0.04624928014006227, 0.014615269647565455, 0.0028371617779749344, -0.0013840746291783367, -6.183388868085215e-5, 8.548004625717443e-5, -4.442028547574055e-6, -3.4885208239390457e-6, 4.82514569024414e-7, 8.740310143336716e-8, -2.3525755287654844e-8, -7.34259540066286e-10, 7.242756561007131e-10, -3.9132744422986586e-11, -1.4430610543508328e-11, 2.0111563898805826e-12, 1.4887321103652866e-13, -5.1033351829108886e-14))
    end
    return p
end
