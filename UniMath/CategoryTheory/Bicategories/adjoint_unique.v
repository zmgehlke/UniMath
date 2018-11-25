(**
Right adjoints, units, counits are unique.

Authors: Dan Frumin, Niels van der Weide

Ported from: https://github.com/nmvdw/groupoids
*)

Require Import UniMath.Foundations.All.
Require Import UniMath.MoreFoundations.All.
Require Import UniMath.CategoryTheory.Categories.
Require Import UniMath.CategoryTheory.Bicategories.Bicat. Import Bicat.Notations.
Require Import UniMath.CategoryTheory.Bicategories.Unitors.
Require Import UniMath.CategoryTheory.Bicategories.BicatAliases.
Require Import UniMath.CategoryTheory.Bicategories.bicategory_laws_2.
Require Import UniMath.CategoryTheory.Bicategories.bicategory_laws.
Require Import UniMath.CategoryTheory.Bicategories.Univalence.
Require Import UniMath.CategoryTheory.Bicategories.transport_laws.
Local Open Scope cat.
Local Open Scope bicategory_scope.

Definition adjoint_unique_map
           {C : bicat}
           {X Y : C}
           (l : C⟦X,Y⟧)
           (r₁ r₂ : C⟦Y,X⟧)
           (A₁ : internal_adjunction_over l r₁)
           (A₂ : internal_adjunction_over l r₂)
  : r₁ ==> r₂
  := (lunitor _) o _ ◅ internal_counit A₁
                 o lassociator _ _ _
                 o internal_unit A₂ ▻ _
                 o rinvunitor _.

Section AdjointUniqueMapCompose.
  Context {C : bicat}
          {X Y : C}.

  Definition help₁
             (f : C⟦X,Y⟧) (g g' : C⟦Y,X⟧)
             (η : id₁ X ==> g ∘ f)
             (η' : id₁ X ==> g' ∘ f)
    : ((g ∘ f) ◅ (η' ▻ g o rinvunitor _))
        o η ▻ g
      = (η ▻ (g' ∘ f ∘ g) o rinvunitor _)
          o η' ▻ g.
  Proof.
    rewrite <- rwhisker_vcomp.
    rewrite !vassocr.
    rewrite !lwhisker_hcomp, !rwhisker_hcomp.
    rewrite rinvunitor_natural.
    rewrite <- !vassocr.
    rewrite <- !interchange.
    rewrite !id2_left, !id2_right.
    rewrite <- (id2_left η).
    rewrite interchange.
    rewrite id2_left.
    apply (maponpaths (λ z, z • _)).
    rewrite left_unit_inv_assoc₂.
    rewrite <- triangle_l_inv.
    rewrite lunitor_V_id_is_left_unit_V_id.
    rewrite !lwhisker_hcomp.
    reflexivity.
  Qed.

  Definition help₂
             (f : C⟦X,Y⟧) (g g' : C⟦Y,X⟧)
             (η : id₁ X ==> g ∘ f)
             (η' : id₁ X ==> g' ∘ f)
    : g ◅ ((f ◅ η') ▻ g)
        o (g ◅ (linvunitor f ▻ g)
             o (lassociator _ _ _ o η ▻ g))
      = g ◅ (rassociator _ _ _)
          o lassociator _ _ _
          o η ▻ (g' ∘ f ∘ g)
          o rinvunitor _
          o η' ▻ g.
  Proof.
    rewrite !vassocr.
    rewrite !(maponpaths (λ z, _ o (_ o z)) (!(vassocr _ _ _))).
    rewrite <- help₁.
    rewrite <- !vassocr.
    apply maponpaths.
    rewrite <- !rwhisker_vcomp.
    rewrite !lwhisker_hcomp, !rwhisker_hcomp.
    rewrite !vassocr.
    rewrite !(maponpaths (fun z => _ o z) (!(vassocr _ _ _))).
    rewrite <- hcomp_identity.
    rewrite hcomp_lassoc.
    rewrite !vassocr.
    rewrite hcomp_lassoc.
    rewrite <- !vassocr.
    apply maponpaths.
    rewrite <- !interchange.
    rewrite !id2_left.
    rewrite hcomp_rassoc.
    rewrite !vassocr.
    rewrite <- (id2_right (id₂ g)).
    rewrite !interchange.
    rewrite triangle_r_inv.
    rewrite id2_right.
    reflexivity.
  Qed.

  Variable (l : C⟦X,Y⟧)
           (r₁ r₂ : C⟦Y,X⟧)
           (A₁ : internal_adjunction_over l r₁)
           (A₂ : internal_adjunction_over l r₂)
           (HA₁ : is_internal_adjunction A₁)
           (HA₂ : is_internal_adjunction A₂).

  Local Notation η₁ := (internal_unit A₁).
  Local Notation η₂ := (internal_unit A₂).
  Local Notation ε₁ := (internal_counit A₁).
  Local Notation ε₂ := (internal_counit A₂).

  Local Notation r₁_to_r₂ := (adjoint_unique_map l r₁ r₂ A₁ A₂).

  Local Notation r₂_to_r₁ := (adjoint_unique_map l r₂ r₁ A₂ A₁).

  Local Definition composition_of_triangles : r₁ ==> r₁
    := (lunitor r₁)
         o r₁ ◅ ε₁
         o lassociator r₁ l r₁
         o (r₁ ◅ ((runitor l)
                    o ε₂ ▻ l
                    o rassociator l r₂ l
                    o l ◅ η₂
                    o linvunitor l) o η₁) ▻ r₁
         o rinvunitor r₁.

  Local Definition composition_of_triangles_is_identity
    : composition_of_triangles = id₂ r₁.
  Proof.
    unfold composition_of_triangles.
    rewrite !vassocr.
    rewrite (internal_triangle1 HA₂).
    rewrite id2_rwhisker, id2_right.
    exact (internal_triangle2 HA₁).
  Qed.

  Local Definition ε₁_natural
    : ε₁ o (runitor l o ε₂ ⋆⋆ id₂ l) ⋆⋆ id₂ r₁
      =
      ε₂ o l ◅ (lunitor r₂ o r₂ ◅ ε₁) o lassociator (l ∘ r₁) r₂ l o lassociator r₁ l (l ∘ r₂).
  Proof.
    rewrite <- rwhisker_vcomp.
    rewrite !vassocr.
    rewrite !(maponpaths (fun z => _ o (_ o z)) (!(vassocr _ _ _))).
    rewrite !rwhisker_hcomp.
    rewrite <- hcomp_lassoc.
    rewrite !vassocr.
    rewrite !(maponpaths (fun z => _ o z) (!(vassocr _ _ _))).
    rewrite <- !rwhisker_hcomp.
    rewrite lunitor_triangle.
    rewrite <- !vassocr.
    rewrite <- vcomp_lunitor.
    rewrite !vassocr.
    rewrite !(maponpaths (fun z => _ o z) (!(vassocr _ _ _))).
    rewrite !lwhisker_hcomp, !rwhisker_hcomp.
    rewrite <- !interchange.
    rewrite !hcomp_identity, id2_right, id2_left.
    rewrite <- (id2_left ε₁).
    rewrite <- (id2_right ε₂).
    rewrite interchange.
    rewrite <- !vassocr, !id2_right, !id2_left.
    rewrite <- runitor_lunitor_identity.
    rewrite <- !rwhisker_hcomp.
    rewrite !vcomp_runitor.
    rewrite !vassocr.
    rewrite <- hcomp_identity.
    rewrite <- hcomp_lassoc.
    rewrite <- !lwhisker_hcomp.
    rewrite <- lwhisker_vcomp.
    rewrite <- !vassocr.
    apply maponpaths.
    rewrite !vassocr.
    apply (maponpaths (λ z, z • ε₁)).
    rewrite <- runitor_triangle.
    rewrite !vassocr.
    rewrite lassociator_rassociator, id2_left.
    reflexivity.
  Qed.

  Definition composition_of_maps : r₂_to_r₁ o r₁_to_r₂ = composition_of_triangles.
  Proof.
    unfold r₁_to_r₂, r₂_to_r₁, composition_of_triangles.
    rewrite !vassocr.
    apply (maponpaths (λ z, z • lunitor r₁)).
    rewrite <- !vassocr.
    apply (maponpaths (λ z, rinvunitor r₁ • z)).
    rewrite <- !lwhisker_vcomp, <- !rwhisker_vcomp.
    rewrite <- !lwhisker_vcomp.
    rewrite <- !vassocr.
    rewrite !lwhisker_hcomp, !rwhisker_hcomp.
    rewrite !vassocr.
    rewrite !(maponpaths (fun z => z • _) (!(vassocr _ _ _))).
    rewrite hcomp_lassoc.
    rewrite !vassocr.
    rewrite !(maponpaths (fun z => (z • _) • _) (!(vassocr _ _ _))).
    rewrite hcomp_lassoc.
    rewrite !vassocr.
    rewrite !(maponpaths (fun z => ((z • _) • _) • _) (!(vassocr _ _ _))).
    rewrite hcomp_lassoc.
    rewrite !vassocr.
    rewrite !(maponpaths (fun z => (((z • _) • _) • _) • _) (!(vassocr _ _ _))).
    rewrite hcomp_lassoc.
    rewrite !vassocr.
    rewrite !(maponpaths (fun z => ((((z • _) • _) • _) • _) • _) (!(vassocr _ _ _))).
    rewrite hcomp_lassoc.
    rewrite !vassocr.
    rewrite <- !lwhisker_hcomp, <- !rwhisker_hcomp.
    rewrite help₂.
    rewrite <- !vassocr.
    apply maponpaths.
    rewrite !lwhisker_hcomp, !rwhisker_hcomp.
    rewrite <- !interchange.
    rewrite !vassocr.
    rewrite <- inverse_pentagon_3.
    rewrite <- !vassocr.
    do 3 rewrite interchange.
    rewrite !id2_left.
    rewrite !vassocr.
    rewrite !(maponpaths (λ z, ((z • _) • _) • _) (!(vassocr _ _ _))).
    rewrite <- hcomp_lassoc.
    rewrite <- interchange.
    rewrite !hcomp_identity.
    rewrite !vassocr, id2_left.
    rewrite ε₁_natural.
    rewrite <- rwhisker_vcomp.
    repeat (rewrite <- (id2_right (id₂ r₁)) ; rewrite interchange).
    rewrite !id2_right.
    rewrite !vassocr.
    apply (maponpaths (λ z, z • _)).
    rewrite !(maponpaths (λ z, ((z • _) • _) • _) (!(vassocr _ _ _))).
    rewrite <- !rwhisker_hcomp.
    rewrite rwhisker_vcomp.
    rewrite rassociator_lassociator, id2_rwhisker, id2_right.
    rewrite !vassocr.
    rewrite !(maponpaths (λ z, (z • _) • _) (!(vassocr _ _ _))).
    rewrite rwhisker_vcomp.
    rewrite rassociator_lassociator, id2_rwhisker, id2_right.
    rewrite !vassocr.
    rewrite !(maponpaths (λ z, z • _) (!(vassocr _ _ _))).
    rewrite !rwhisker_hcomp.
    rewrite <- hcomp_lassoc.
    rewrite <- !vassocr.
    rewrite <- hcomp_lassoc.
    rewrite !vassocr.
    apply (maponpaths (λ z, z • _)).
    rewrite !hcomp_identity.
    rewrite <- !vassocr.
    rewrite <- !interchange.
    rewrite !vassocr, !id2_left, !id2_right.
    rewrite <- (id2_right (lunitor r₂)).
    rewrite !vassocr.
    rewrite <- (id2_left η₁).
    rewrite interchange.
    rewrite !vassocr.
    rewrite !id2_right, !id2_left.
    apply (maponpaths (λ z, z • _)).
    rewrite rinvunitor_natural.
    reflexivity.
  Qed.
End AdjointUniqueMapCompose.

Section UniquenessAdjoint.
  Context {C : bicat}
          {X Y : C}.
  Variable (l : C⟦X,Y⟧)
           (r₁ r₂ : C⟦Y,X⟧)
           (A₁ : internal_adjunction_over l r₁)
           (A₂ : internal_adjunction_over l r₂)
           (HA₁ : is_internal_adjunction A₁)
           (HA₂ : is_internal_adjunction A₂).

  Local Notation η₁ := (internal_unit A₁).
  Local Notation η₂ := (internal_unit A₂).
  Local Notation ε₁ := (internal_counit A₁).
  Local Notation ε₂ := (internal_counit A₂).

  Local Notation r₁_to_r₂ := (adjoint_unique_map l r₁ r₂ A₁ A₂).

  Local Notation r₂_to_r₁ := (adjoint_unique_map l r₂ r₁ A₂ A₁).

  Definition adjoint_unique_map_iso
    : is_invertible_2cell r₁_to_r₂.
  Proof.
    use tpair.
    - exact r₂_to_r₁.
    - cbn.
      split.
      + rewrite (composition_of_maps l r₁ r₂ A₁ A₂).
        rewrite (composition_of_triangles_is_identity _ _ _ _ _ HA₁ HA₂).
        reflexivity.
      + rewrite (composition_of_maps l r₂ r₁ A₂ A₁).
        rewrite (composition_of_triangles_is_identity _ _ _ _ _ HA₂ HA₁).
        reflexivity.
  Defined.

  Definition remove_η₂
    : r₂ ◅ (runitor l o ε₁ ▻ l o rassociator l r₁ l o l ◅ η₁)
         o lassociator (id₁ X) l r₂
         o linvunitor (r₂ ∘ l)
         o η₂
      = η₂.
  Proof.
    refine (_ @ id2_right _).
    apply maponpaths.
    rewrite <- hcomp_identity.
    rewrite <- (internal_triangle1 HA₁).
    rewrite <- rwhisker_hcomp.
    rewrite <- !rwhisker_vcomp.
    rewrite linvunitor_assoc.
    rewrite <- !vassocr.
    apply maponpaths.
    rewrite !vassocr.
    rewrite rassociator_lassociator, id2_left.
    reflexivity.
  Qed.

  Definition help_triangle_η
    : (η₂ ▻ r₁) ▻ l o (rinvunitor r₁ ▻ l o η₁)
      =
      (rassociator l r₁ (r₂ ∘ l))
        o rassociator (r₁ ∘ l) l r₂
        o r₂ ◅ (l ◅ η₁)
        o lassociator (id₁ X) l r₂
        o linvunitor (r₂ ∘ l) o η₂.
  Proof.
    rewrite !vassocr.
    rewrite !(maponpaths (λ z, (z • _) • _) (!(vassocr _ _ _))).
    rewrite !lwhisker_hcomp, !rwhisker_hcomp.
    rewrite <- hcomp_lassoc.
    rewrite !vassocr.
    rewrite !(maponpaths (λ z, z • _) (!(vassocr _ _ _))).
    rewrite lassociator_rassociator, id2_right.
    rewrite !vassocr.
    use vcomp_move_L_Mp.
    { is_iso. }
    cbn.
    rewrite linvunitor_natural.
    rewrite <- !vassocr.
    rewrite <- interchange, id2_left, hcomp_identity, id2_right.
    rewrite hcomp_lassoc, hcomp_identity.
    rewrite lunitor_V_id_is_left_unit_V_id.
    rewrite !vassocr.
    rewrite !(maponpaths (λ z, z • _) (!(vassocr _ _ _))).
    rewrite <- lwhisker_hcomp.
    rewrite <- left_unit_inv_assoc₂.
    rewrite rinvunitor_natural.
    rewrite <- !vassocr.
    apply maponpaths.
    rewrite <- interchange.
    rewrite !id2_right, id2_left.
    reflexivity.
  Qed.

  Definition transport_unit
    : r₁_to_r₂ ▻ l o η₁ = η₂.
  Proof.
    rewrite <- remove_η₂.
    unfold r₁_to_r₂.
    rewrite <- !lwhisker_vcomp.
    rewrite !vassocr.
    rewrite help_triangle_η.
    rewrite linvunitor_assoc.
    rewrite !vassocr.
    rewrite !(maponpaths (λ z, ((((((z • _) • _) • _) • _) • _) • _)) (!(vassocr _ _ _))).
    rewrite rassociator_lassociator, id2_right.
    rewrite !(maponpaths (λ z, (((((z • _) • _) • _) • _) • _)) (!(vassocr _ _ _))).
    rewrite rwhisker_vcomp.
    rewrite <- !vassocr.
    rewrite <- !rwhisker_vcomp.
    repeat (apply maponpaths).
    rewrite <- !vassocr.
    apply maponpaths.
    rewrite !vassocr.
    rewrite rassociator_lassociator, id2_left.
    rewrite <- !vassocr.
    apply maponpaths.
    rewrite !vassocr.
    rewrite inverse_pentagon.
    rewrite <- !vassocr.
    rewrite !rwhisker_hcomp.
    apply maponpaths.
    rewrite !vassocr.
    rewrite !(maponpaths (λ z, (z • _) • _) (!(vassocr _ _ _))).
    rewrite <- !lwhisker_hcomp.
    rewrite !lwhisker_vcomp.
    rewrite rassociator_lassociator.
    rewrite lwhisker_id2, id2_right.
    rewrite !lwhisker_hcomp.
    rewrite <- hcomp_rassoc.
    rewrite <- !vassocr.
    apply maponpaths.
    apply triangle_l.
  Qed.

  Definition help_triangle_ε
    : ε₂ o l ◅ (lunitor r₂ o r₂ ◅ ε₁)
      = ε₁ o runitor (l ∘ r₁)
           o lassociator _ _ _
           o ε₂ ▻ l ▻ r₁
           o rassociator _ _ _
           o rassociator _ _ _.
  Proof.
    rewrite !vassocr.
    rewrite !(maponpaths (λ z, (z • _) • _) (!(vassocr _ _ _))).
    rewrite !lwhisker_hcomp, !rwhisker_hcomp.
    rewrite hcomp_lassoc.
    rewrite !vassocr.
    rewrite !(maponpaths (λ z, ((z • _) • _) • _) (!(vassocr _ _ _))).
    rewrite rassociator_lassociator, id2_right.
    rewrite <- !vassocr.
    use vcomp_move_L_pM.
    { is_iso. }
    cbn.
    rewrite <- runitor_natural.
    rewrite !vassocr.
    rewrite hcomp_identity.
    rewrite <- interchange.
    rewrite !id2_right, id2_left.
    rewrite <- !rwhisker_hcomp.
    rewrite <- rwhisker_vcomp.
    rewrite !vassocr.
    rewrite !rwhisker_hcomp.
    rewrite <- hcomp_lassoc.
    rewrite !(maponpaths (λ z, z • _) (!(vassocr _ _ _))).
    rewrite <- !rwhisker_hcomp.
    rewrite lunitor_triangle.
    rewrite <- !vassocr.
    rewrite <- vcomp_lunitor.
    rewrite lunitor_runitor_identity.
    rewrite !vassocr.
    apply (maponpaths (λ z, z • _)).
    rewrite lwhisker_hcomp, rwhisker_hcomp.
    rewrite hcomp_identity.
    rewrite <- interchange.
    rewrite !id2_right, !id2_left.
    reflexivity.
  Qed.

  Definition remove_ε₁
    : ε₁ o runitor (l ∘ r₁)
         o lassociator r₁ l (id₁ Y)
         o (ε₂ ▻ l o rassociator l r₂ l o l ◅ η₂ o linvunitor l) ▻ r₁
      = ε₁.
  Proof.
    rewrite !vassocr.
    rewrite !(maponpaths (λ z, z • _) (!(vassocr _ _ _))).
    rewrite <- runitor_triangle.
    rewrite !vassocr.
    refine (_ @ id2_left _).
    apply (maponpaths (λ z, z • _)).
    rewrite <- !vassocr.
    rewrite <- lwhisker_id2.
    rewrite <- (internal_triangle1 HA₂).
    rewrite <- !lwhisker_vcomp.
    rewrite <- !vassocr.
    repeat (apply maponpaths).
    rewrite !vassocr.
    rewrite lassociator_rassociator.
    apply id2_left.
  Qed.

  Definition transport_counit
    : ε₂ o l ◅ r₁_to_r₂ = ε₁.
  Proof.
    rewrite <- remove_ε₁.
    unfold r₁_to_r₂.
    do 3 rewrite <- rwhisker_vcomp.
    rewrite <- !vassocr.
    rewrite help_triangle_ε.
    rewrite !vassocr.
    rewrite <- !lwhisker_vcomp.
    repeat (apply (maponpaths (λ z, z • _))).
    use vcomp_move_L_Mp.
    { is_iso. }
    cbn.
    rewrite (maponpaths (λ z, z • _) (!(vassocr _ _ _))).
    rewrite inverse_pentagon.
    rewrite !vassocr.
    rewrite !lwhisker_vcomp.
    rewrite !lwhisker_hcomp, !rwhisker_hcomp.
    rewrite <- !vassocr.
    rewrite (maponpaths (λ z, _ • (_ • z)) (vassocr _ _ _)).
    rewrite <- interchange.
    rewrite lassociator_rassociator, !id2_right, hcomp_identity.
    rewrite id2_left.
    rewrite <- interchange.
    rewrite rassociator_lassociator, !id2_right, hcomp_identity.
    rewrite id2_right.
    rewrite <- !lwhisker_hcomp, <- !rwhisker_hcomp.
    rewrite <- lwhisker_vcomp.
    rewrite !lwhisker_hcomp, !rwhisker_hcomp.
    rewrite triangle_r_inv.
    rewrite <- !vassocr.
    apply maponpaths.
    apply hcomp_rassoc.
  Qed.
End UniquenessAdjoint.

Definition unique_internal_adjoint_equivalence
           {C : bicat}
           {X Y : C}
           (l : C⟦X,Y⟧)
           (HC : is_univalent_2_1 C)
           (A₁ : is_internal_left_adjoint_internal_equivalence l)
           (A₂ : is_internal_left_adjoint_internal_equivalence l)
  : A₁ = A₂.
Proof.
  use total2_paths_f.
  - cbn.
    apply (isotoid_2_1 HC).
    refine (adjoint_unique_map l (pr1 A₁) (pr1 A₂) A₁ A₂ ,, _).
    apply adjoint_unique_map_iso.
    + exact A₁.
    + exact A₂.
  - rewrite transportf_total2.
    use subtypeEquality'.
    + unfold internal_adjunction_over ; cbn.
      rewrite (transportf_dirprod _ _ _ (pr1 A₁ ,, pr12 A₁) (pr1 A₂ ,, pr12 A₂)) ; cbn.
      use pathsdirprod.
      * rewrite transport_two_cell_FlFr.
        rewrite !maponpaths_for_constant_function ; cbn.
        rewrite id2_left.
        rewrite <- idtoiso_2_1_lwhisker.
        unfold isotoid_2_1.
        pose (homotweqinvweq (idtoiso_2_1 (pr1 A₁) (pr1 A₂),, HC Y X (pr1 A₁) (pr1 A₂))) as p.
        cbn in p.
        rewrite p ; clear p.
        cbn.
        apply transport_unit.
        exact A₁.
      * rewrite transport_two_cell_FlFr.
        rewrite !maponpaths_for_constant_function ; cbn.
        rewrite id2_right.
        use vcomp_move_R_pM.
        { is_iso. }
        cbn.
        rewrite <- idtoiso_2_1_rwhisker.
        unfold isotoid_2_1.
        pose (homotweqinvweq (idtoiso_2_1 (pr1 A₁) (pr1 A₂),, HC Y X (pr1 A₁) (pr1 A₂))) as p.
        cbn in p.
        rewrite p ; clear p.
        cbn.
        symmetry.
        apply transport_counit.
        exact A₂.
    + cbn.
      intros x y.
      apply isapropdirprod.
      * apply isapropdirprod ; apply isaprop_is_invertible_2cell.
      * apply isapropdirprod ; apply C.
Defined.

Definition path_internal_adjoint_equivalence
           {C : bicat}
           {X Y : C}
           (HC : is_univalent_2_1 C)
           (A₁ A₂ : internal_adjoint_equivalence X Y)
           (H : internal_left_adjoint A₁ = internal_left_adjoint A₂)
  : A₁ = A₂.
Proof.
  use total2_paths_f.
  - exact H.
  - apply unique_internal_adjoint_equivalence.
    apply HC.
Defined.
