Require Import UniMath.Foundations.Sets.
Require Import UniMath.MoreFoundations.All.
Require Import UniMath.Algebra.Rigs_and_Rings.
Require Import UniMath.Algebra.Monoids_and_Groups.
Require Import UniMath.Algebra.Modules.Core.
Require Import UniMath.Algebra.Modules.Submodule.

Section quotmod_rel.

  Context {R : rng}
          (M : module R).


  Local Open Scope module_scope.
  Definition isacthrel (E : hrel M) : UU :=
    ∏ r a b, E a b -> E (r * a) (r * b).

  Definition monoideqrel : UU :=
    total2 (λ E : eqrel M, isbinophrel E × isacthrel E).
  Definition hrelmonoideqrel (E : monoideqrel) : eqrel M := pr1 E.
  Coercion hrelmonoideqrel : monoideqrel >-> eqrel.

  Definition binophrelmonoideqrel (E : monoideqrel) : binopeqrel := binopeqrelpair E (pr1 (pr2 E)).
  Coercion binophrelmonoideqrel : monoideqrel >-> binopeqrel.

  Definition isacthrelmonoideqrel (E : monoideqrel) : isacthrel E := pr2 (pr2 E).
  Coercion isacthrelmonoideqrel : monoideqrel >-> isacthrel.

  Definition mk_monoideqrel (E : eqrel M) : isbinophrel E -> isacthrel E -> monoideqrel :=
    λ H0 H1, (E,,(H0,,H1)).

End quotmod_rel.

Section quotmod_submodule.

  Context {R : rng}
          (M : module R)
          (A : submodule M).

  Local Notation "x + y" := (@op _ x y).
  Local Notation "x - y" := (@op _ x (grinv _ y)).
  Local Open Scope module_scope.

  Definition eqrelsubmodule : eqrel M.
  Proof.
    use eqrelconstr.
    - exact (λ m m', A (m - m')).
    - intros x y z xy yz.
      generalize (submoduleadd A (x - y) (y - z) xy yz).
      now rewrite (assocax M), <- (assocax M (grinv _ y) y), grlinvax, lunax.
    - intros x.
      generalize (submodule0 A).
      now rewrite <- (grrinvax M x).
    - intros x y axy.
      generalize (submoduleinv A (x - y) axy).
      now rewrite grinvop, grinvinv.
  Defined.

  Definition monoideqrelsubmodule : monoideqrel M.
  Proof.
    use mk_monoideqrel.
    - exact eqrelsubmodule.
    - split.
      + intros a b c.
        assert (H : a - b = c + a - (c + b)).
        {
          etrans; [|eapply (maponpaths (λ z, z - (c + b))); apply (commax M)];
            rewrite assocax.
          apply maponpaths.
          now rewrite grinvop, commax, assocax, grlinvax, runax.
        }
        simpl in *.
        now rewrite H.
      + intros a b c.
        assert (H : a - b = a + c - (b + c)).
        {
          rewrite assocax.
          apply maponpaths.
          now rewrite grinvop, <- (assocax M), grrinvax, lunax.
        }
        simpl in *.
        now rewrite H.
    - intros r m m'.
      assert (H : (r * m) - (r * m') = r * (m - m')) by
          now rewrite module_inv_mult, module_mult_is_ldistr.
      generalize (submodulemult A r (m - m')).
      simpl in *.
      now rewrite H.
  Defined.

End quotmod_submodule.

Section quotmod_def.

  Context {R : rng}
          (M : module R)
          (E : monoideqrel M).

  Local Notation "x + y" := (@op _ x y).
  Local Notation "x - y" := (@op _ x (grinv _ y)).
  Local Open Scope module_scope.

  Definition quotmod_abgr : abgr := abgrquot E.

  Definition quotmod_rngact (r : R) : quotmod_abgr -> quotmod_abgr.
  Proof.
    use setquotuniv.
    - intros m.
      exact (setquotpr E (r * m)).
    - intros m m' Hmm'.
      apply weqpathsinsetquot.
      now apply isacthrelmonoideqrel.
  Defined.

  Definition quotmod_rngmap : R -> rngofendabgr quotmod_abgr.
  Proof.
    intros r. use tpair.
    + exact (quotmod_rngact r).
    + use mk_ismonoidfun.
      * use mk_isbinopfun.
        use (setquotuniv2prop E (λ a b, hProppair _ _)); [use isasetsetquot|].
        intros m m'.
        unfold quotmod_rngact, setquotfun2;
          rewrite (setquotunivcomm E), (setquotunivcomm E);
          simpl; unfold setquotfun2;
            rewrite (setquotuniv2comm E), (setquotuniv2comm E), (setquotunivcomm E).
        apply weqpathsinsetquot.
        assert (H : r * (m + m') = r * m + r * m') by use module_mult_is_ldistr.
        simpl in H; rewrite H.
        use eqrelrefl.
      * unfold unel, quotmod_rngact; simpl; rewrite (setquotunivcomm E).
        apply maponpaths.
        apply module_mult_1.
  Defined.

  Definition quotmod_rngfun : rngfun R (rngofendabgr quotmod_abgr).
  Proof.
    unfold rngfun. unfold rigfun.
    use rigfunconstr.
    - use quotmod_rngmap.
    - use mk_isrigfun;
        [ use mk_ismonoidfun | use mk_ismonoidfun ];
        [ use mk_isbinopfun; intros r r' | | use mk_isbinopfun; intros r r' | ].
      all: use monoidfun_paths; use funextfun.
      all: use (setquotunivprop E (λ m, hProppair _ _)); [use isasetsetquot|].
      all: intros m.
      all: simpl; unfold unel, quotmod_rngact, funcomp.
      all: [> do 3 rewrite (setquotunivcomm E) | rewrite (setquotunivcomm E)
            | do 3 rewrite (setquotunivcomm E) | rewrite (setquotunivcomm E)].
      all: use maponpaths; simpl.
      + use module_mult_is_rdistr.
      + use module_mult_0_to_0.
      + use module_mult_assoc.
      + use module_mult_unel2.
  Defined.

  Definition quotmod_mod_struct : module_struct R quotmod_abgr.
  Proof.
    unfold module_struct.
    exact quotmod_rngfun.
  Defined.

  Definition quotmod : module R.
  Proof.
    use modulepair.
    - exact quotmod_abgr.
    - exact quotmod_mod_struct.
  Defined.

  Definition quotmod_quotmap : modulefun M quotmod.
  Proof.
    use modulefunpair.
    - exact (setquotpr E).
    - now use (ismodulefunpair (mk_isbinopfun _)).
  Defined.

  Definition quotmoduniv
             (N : module R)
             (f : modulefun M N)
             (is : iscomprelfun E f) :
    modulefun quotmod N.
  Proof.
    use modulefunpair.
    - now use (setquotuniv E _ f).
    - use ismodulefunpair.
      + use mk_isbinopfun.
        use (setquotuniv2prop E (λ m n, hProppair _ _)); [use isasetmodule|].
        intros m m'.
        simpl.
        unfold op, setquotfun2.
        rewrite setquotuniv2comm.
        do 3 rewrite (setquotunivcomm E).
        apply modulefun_to_isbinopfun.
      + intros r.
        use (setquotunivprop E (λ m, hProppair _ _)); [use isasetmodule|].
        intros m.
        assert (H : r * quotmod_quotmap m = quotmod_quotmap (r * m)) by
            use (! modulefun_to_islinear _ _ _).
        simpl in H. simpl.
        rewrite H.
        do 2 rewrite (setquotunivcomm E).
        apply modulefun_to_islinear.
  Defined.

End quotmod_def.
