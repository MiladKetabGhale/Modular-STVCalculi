Require Import Coq.Init.Peano.
Require Import Notations.
Require Import Coq.Lists.List.
Require Import Coq.Numbers.Natural.Peano.NPeano.
Require Import Coq.omega.Omega.
Require Import Coq.Arith.Le.
Require Import Coq.Arith.Compare_dec.
Require Import Coq.Numbers.NatInt.NZMul.
Require Import Coq.Structures.OrdersFacts.
Require Import Coq.ZArith.Znat. 
Require Import Coq.QArith.QArith_base.
Require Import  Coq.QArith.QOrderedType.
Require Import QArith_base Equalities Orders OrdersTac.
Require Import Coq.Sorting.Permutation.
Require Import Wf.
Require Import Lexicographic_Product.
Require Import Qreduction.
Require Import Coq.Bool.Bool.
Require Import Inverse_Image. 
Require Import Coq.Bool.Sumbool.
Require Import Coq.Sorting.Mergesort.
Import ListNotations.
Require Import Coq.Program.Basics.
Require Import Coq.Arith.Wf_nat.
Require Import Program.
Require Import  Recdef.
Add LoadPath "/home/users/u5711205/Modular-STVCalculi/".
Require Export Parameters.
Require Import FrameBase.
Add LoadPath "/home/users/u5711205/Modular-STVCalculi/ActSTV".
Require Export Instantiation.
Import Instantiate.
Import M.
Import QSort.

(*Module Act.*)

Section ACT.


Definition ACT_InitStep (prem :Machine_States) (conc :Machine_States): Prop :=
 exists ba ba',  
  ((prem = (initial  ba)) /\
  (ba' = (Filter ba)) /\
  (conc = state  (ba', [nty], nas, (nbdy, nbdy), emp_elec , all_hopeful))).

Definition ACT_count (prem: Machine_States) (conc: Machine_States) : Prop :=
 exists ba t nt p np bl h e,                (** count the ballots requiring attention **)
  prem = state (ba, t, p, bl, e, h) /\     (* if we are in an intermediate state of the count *) 
  [] <> ba /\                                        (* and there are ballots requiring attention *)
  (forall c, if (cand_in_dec c (proj1_sig h)) 
      then 
  (exists l,                     
    np(c) = p(c) ++ [l] /\                       
    (forall b, In (proj1_sig (fst b)) (map (fun (d:ballot) => (proj1_sig (fst d))) l) <-> 
                                                               fcc ba (proj1_sig h) c b) /\ 
    (nt (c) = SUM (np(c)))) 
      else ((nt c) = (hd nty t) c) /\ (np c) = (p c)) /\                 
  conc = state ([], nt :: t, np, bl, e, h).     

Definition ACT_hwin (prem: Machine_States) (conc: Machine_States) : Prop :=
  exists w ba t p bl e h,                            
   prem = state (ba, t, p, bl, e, h) /\           
   length (proj1_sig e) + length (proj1_sig h) <= st /\ 
   w = (proj1_sig e) ++ (proj1_sig h) /\                        
   conc = winners (w).

Definition ACT_ewin (prem: Machine_States) (conc: Machine_States) : Prop :=
  exists w ba t p bl e h,                    (** elected win **)
   prem = state (ba, t, p, bl, e, h) /\   (* if at any time *)
   length (proj1_sig e) = st /\             (* we have as many elected candidates as seats *) 
   w = (proj1_sig e) /\                        (* and the winners are precisely the electeds *)
   conc = winners (w).                      (* they are declared the winners *)

Definition ACT_elim (prem: Machine_States) (conc: Machine_States) : Prop :=
  exists nba t p np bl2 e h nh,                    
   prem = state ([], t, p, ([], bl2), e, h) /\         
   length (proj1_sig e) + length (proj1_sig h) > st /\ 
   (forall c, In c (proj1_sig h) -> (hd nty t(c) < quota)%Q) /\ 
   exists c,                                            
     ((forall d, In d (proj1_sig h) -> (hd nty t(c) <= hd nty t(d)))%Q /\            
     eqe c (proj1_sig nh) (proj1_sig h) /\                                   
     nba = flat_map (fun x => x) (p c) /\                                   
     np(c)=[] /\                                       
     (forall d, d <> c -> np (d) = p (d)) /\                       
   conc = state (nba, t, np, ([], []), e, nh)). 

Definition ACT_TransferElected (prem: Machine_States) (conc: Machine_States) : Prop :=
 exists nba t p np bl nbl h e,
  prem = state ([], t, p, bl, e, h) /\
  (length (proj1_sig e) < st) /\
  (forall c, In c (proj1_sig h) -> ((hd nty t) c < quota)%Q) /\
  exists l c bl2,
   (bl = (c :: l,bl2) /\
   nbl = (l,bl2) /\
   nba = last (p c) [] /\ np(c) = [] /\
     (forall d, d <> c -> np(d) = p(d))) /\
   conc = state (nba, t, np, nbl, e, h).

 (*
 Definition CADE_elect 
  (prem: Machine_States) (conc: Machine_States) : Prop :=
   exists nba t p np bl nbl  nh h e ne,
   (1) prem = state ([], t, p, bl, e, h) /\ 
   (2) exists c,                                                                  
   (3)  length (proj1_sig e) + 1 <= st /\    
   (4)  In c (proj1_sig h) /\ (hd nty t (c) >= quota)%Q /\      
   (5)  eqe c (proj1_sig e) (proj1_sig ne) /\          
   (6)  (forall d, In d (proj1_sig nh) <-> 
         In d cand_all /\ (~ In d (proj1_sig ne))) /\     
   (7)  (forall d, In d cand_all -> (np d = [])) /\ 
   (8)  (fst nbl = []) /\
   (9)  (nba = Append_All cand_all p) /\           
   (10) conc = state (nba, t, np, nbl, ne, nh).      
 *)


 Definition ACT_Elect (prem: Machine_States) (conc: Machine_States) : Prop :=
  exists (nba: list ballot) t p np (bl nbl: (list cand) * (list cand)) nh h e ne,
    prem = state ([], t, p, bl, e, h) /\
    exists l,
     (l <> [] /\
     length l <= st - length (proj1_sig e) /\
     (forall c, In c l -> In c (proj1_sig h) /\ (hd nty t (c) >= quota)%Q) /\    
     ordered (hd nty t) l /\
     Leqe l (proj1_sig nh) (proj1_sig h) /\
     Leqe l (proj1_sig e) (proj1_sig ne) /\
     (forall c, In c l -> ((np c) = map (map (fun (b : ballot) =>
      (fst b, (Qred (snd b * (Update_transVal c p (hd nty t))))%Q))) [(last (p c) [])])) /\
     (forall c, ~ In c l -> np (c) = p (c)) /\
     fst nbl = (fst bl) ++ l) /\ (nba = []) /\
   conc = state ([], t, np, nbl, ne, nh).

(* (e ne: {l : list cand | length l <= st })
Definition ACT_TransferElected2 (prem: Machine_States) (conc: Machine_States) :=
 exists nba t p np bl nbl h e,         
  prem = state ([], t, p, bl, e, h) /\ 
    (length (proj1_sig e) < st) /\
    (forall c, In c (proj1_sig h) -> ((hd nty t) c < quota)%Q) /\       
    exists l c,                          
     (bl = (c :: l, []) /\                   
     nbl = (l, []) /\                          
     nba = concat (p c) /\
     concat (p c') = [] /\           
     np(c) = [] /\                                 
     (forall d, d <> c -> np(d) = p(d))) /\    
   conc = state (nba, t, np, nbl, e, h). 
*)

Definition ACT_TransferElim (prem: Machine_States) (conc: Machine_States) :=
 exists nba t p np bl nbl h e,         
  prem = state ([], t, p, bl, e, h) /\ 
    (length (proj1_sig e) < st) /\
    (forall c, In c (proj1_sig h) -> ((hd nty t) c < quota)%Q) /\       
    exists bl1 c' l',                          
     (bl = (bl1, c'::l') /\                   
    (*(match  (concat (np c')) with
        [] => nbl = (bl1, l')
       | _ => nbl = (bl1, c'::l')
      end) /\*)
      (concat (p c') <> []) /\  
      nbl = (bl1, c'::l') /\
      let x:= (groupbysimple _ (sort (concat (p c')))) in
       (nba = last x []) /\
       np c' = (removelast x) /\
       (*/\
       (match concat (np c') with [] => (nbl = (bl1,l')) | _ => (nbl = (bl1,c'::l')) end) *)
       (forall d, d <> c' -> np(d) = p(d))) /\    
   conc = state (nba, t, np, nbl, e, h). 

Lemma ACTInitStep_SanityCheck_App : SanityCheck_Initial_App ACT_InitStep.
Proof.
 unfold SanityCheck_Initial_App.  
 intros.
 exists (state (Filter ba, [nty], nas, (nbdy, nbdy), emp_elec, all_hopeful)). 
 split. auto.
 unfold ACT_InitStep.
 exists ba.
 exists (Filter ba).
 split. assumption.
 split;auto. 
Qed. 

Lemma ACTInitStep_SanityCheck_Red: SanityCheck_Initial_Red ACT_InitStep.
 unfold SanityCheck_Initial_Red.
 intros.
 unfold ACT_InitStep in H.
 destruct H as [ba [ba' H1]]. 
 exists ba. exists ba'. exists [nty]. exists nas. exists (nbdy, nbdy). exists emp_elec. exists all_hopeful.
 split;auto.
 intuition.
 intuition.
Qed.

Hypothesis Bl_hopeful_NoIntersect : forall j: Machine_States, forall ba t p bl e h, j = state (ba,t,p,bl,e,h) ->
 (forall c, In c (snd bl) -> ~ In c (proj1_sig h)) * (forall c, In c (fst bl) -> ~ In c (snd bl)).

Lemma ACTCount_SanityCheck_App : SanityCheck_Count_App ACT_count.
Proof.
 unfold SanityCheck_Count_App. 
 intros.
 exists (state ([], (fun (c:cand) =>  if (cand_in_dec c (proj1_sig h)) then SUM (p (c) ++ [list_is_first_hopeful c (proj1_sig h) ba]) else (hd nty t) c) :: t, fun (c:cand) => (if (cand_in_dec c (proj1_sig h)) then (p (c) ++ [list_is_first_hopeful c (proj1_sig h) ba]) else (p c)), bl, e, h)).
 unfold ACT_count.
 exists ba.
 exists t.
 exists ((fun (c:cand) =>  if (cand_in_dec c  (proj1_sig h)) then SUM (p (c) ++ [list_is_first_hopeful c (proj1_sig h) ba]) else ((hd nty t) c))).
 exists p.
 exists (fun (c:cand) => (if (cand_in_dec c (proj1_sig h)) then (p (c) ++ [list_is_first_hopeful c (proj1_sig h) ba]) else (p c))). 
 exists bl.
 exists h.
 exists e.
 split; auto.
 split; auto.
 split.
 intro c.
 destruct (cand_in_dec c (proj1_sig h)).
 exists (list_is_first_hopeful c (proj1_sig h) ba).
 split; auto.
 split.
 intro b.   
 apply (listballot_fcc ba t p bl e h quota c i b). 
 simpl.
 destruct (cand_in_dec c (proj1_sig h)). auto.
 contradict n. assumption.
 simpl.
 destruct (cand_in_dec c (proj1_sig h)).
 contradict n. assumption.
 auto. auto.
Qed.

Lemma ACTCount_SanityCheck_Red: SanityCheck_Count_Red ACT_count.
 Proof.
 unfold SanityCheck_Count_Red.
 intros.
 unfold ACT_count in H.
 destruct H as [ba [t [nt [ p0 [np [bl [h [e H1]]]]]]]].
 destruct H1 as [H11 [H12 [H13 H14]]].
 assert (old_new_pile_equal_bl: forall c, In c (snd bl) -> p0 c = np c).
 specialize (Bl_hopeful_NoIntersect p ba t p0 bl e h H11). 
 intros c0  Hyp.
 destruct Bl_hopeful_NoIntersect as [NoIntersect1 NoIntersect2].
 specialize (NoIntersect1 c0 Hyp).
 specialize (H13 c0).
 destruct (cand_in_dec c0 (proj1_sig h)).
 contradict NoIntersect1.
 assumption.
 intuition.
 exists ba; exists ([]: list ballot); exists t. exists nt; exists p0. 
 exists np; exists bl; exists e; exists h. split. intuition. 
 split; intuition.
 specialize (list_nonempty ballot ba). intro Hyp.
 intuition.
 destruct H as [b [l Hyp1]].
 rewrite Hyp1.
 simpl. 
 omega. 
 assert (hyp2: forall c, In c (snd bl) -> length (concat (p0 c)) = length (concat (np c))).
 intros.
 specialize (old_new_pile_equal_bl c0 H). 
 rewrite old_new_pile_equal_bl.
 reflexivity.
 specialize (map_ext_in (fun c0 => length (concat (p0 c0))) (fun c0 => length (concat (np c0))) (snd bl) hyp2).
 intro.
 rewrite H. auto.
Qed.

Lemma  ACTHwin_SanityCheck_App : SanityCheck_Hwin_App ACT_hwin.                 
Proof.
 unfold SanityCheck_Hwin_App.
 intros.
 unfold ACT_hwin.
 exists (winners ((proj1_sig e) ++ (proj1_sig h))).
 exists ((proj1_sig e) ++ (proj1_sig h)).
 exists ba; exists t; exists p; exists bl; exists e; exists h.  
 auto.
Qed.

Lemma ACTHwin_SanityCheck_Red : SanityCheck_Hwin_Red ACT_hwin.
Proof.
 unfold SanityCheck_Hwin_Red.
 intros.
 unfold ACT_hwin in H. 
 destruct H as [w [ba [t [p [bl [e [h H1]]]]]]]. 
 exists w; exists ba; exists t; exists p; exists bl; exists e; exists h. 
 intuition.
Qed.

Lemma ACTEwin_SanityCheck_App : SanityCheck_Ewin_App ACT_ewin.
Proof.
 unfold SanityCheck_Ewin_App.
 intros.
 unfold ACT_ewin.
 exists (winners (proj1_sig e)). 
 exists (proj1_sig e). exists ba. exists t. exists p. exists bl. exists e. exists h.
 intuition.
Qed.

Lemma ACTEwin_SanityCheck_Red : SanityCheck_Ewin_Red ACT_ewin.
Proof.
 unfold SanityCheck_Ewin_Red.
 intros.
 unfold ACT_ewin in H.
 destruct H as [w [ba [t [p [bl [e [h H1]]]]]]].
 exists w. exists ba. exists t. exists p. exists bl. exists e. exists h. 
 intuition.
 rewrite <- H0.
 assumption.
Qed.

Lemma ACTElim_SanityCheck_App : SanityCheck_Elim_App ACT_elim.
Proof.
 unfold SanityCheck_Elim_App.
 intros.
 unfold ACT_elim.
 specialize (list_min cand (proj1_sig h) (hd nty t)). intro min_hopeful.
 destruct min_hopeful.
 rewrite e0 in H0.
 destruct H0 as [H01 H02].
 destruct e.
 simpl in H01.
 omega.
 destruct s as [min [s1 s2]].
 specialize (remc_nodup (proj1_sig h) min (proj2_sig h) s1);intro H'1.
 exists (state (flat_map (fun x => x) (p min), t, fun d => if (cand_eq_dec d min) then [] else (p d),
                                                ([], []), e, exist _ (remc min (proj1_sig h)) H'1)). 
 exists (flat_map (fun x => x) (p min)).
 exists t. exists p. exists (fun d => if (cand_eq_dec d min) then [] else (p d)). exists bl2. exists e. exists h. 
 exists (exist _ (remc min (proj1_sig h)) H'1).
 intuition.
(* exists bl2. 
 intuition.
 simpl.*)
 exists min.
 intuition.
 apply (remc_ok min (proj1_sig h) (proj2_sig h) s1).
 destruct (cand_eq_dec min min) as [i | j]. reflexivity.
 contradict j. auto.
 destruct (cand_eq_dec d min) as [i | j]. contradiction i. reflexivity.

 exists min.
 intuition.
 apply (remc_ok min (proj1_sig h) (proj2_sig h) s1).
 destruct (cand_eq_dec min min) as [i | j]. auto. contradict j. reflexivity.
 destruct (cand_eq_dec d min) as [i | j]. contradiction. auto.
Qed.

Lemma ACTElim_SanityCheck_Red : SanityCheck_Elim_Red ACT_elim.
 Proof.
 unfold SanityCheck_Elim_Red.
 intros. 
 unfold ACT_elim in H.
 destruct H as [nba [t [p [np [bl2 [e [h [nh  H1]]]]]]]].
 destruct H1 as [H11 [H12 [H13 H14]]].
 destruct H14 as [weakest H141]. 
 exists nba. exists t. exists p. exists np. exists e. exists h. exists nh.  exists bl2. exists ([]: list cand). 
 intuition.
 unfold eqe in H1.
 destruct H1 as [l1 [l2 [H' [H'' [H''' H'''']]]]].
 rewrite H'.
 rewrite H''.
 assert (Hyp : length (l1 ++ [weakest] ++ l2) = (length l1 + (length ([weakest] ++ l2)))% nat).
 simpl.
 rewrite (app_length).
 simpl. auto.  
 rewrite Hyp.
 simpl.
 rewrite (app_length). omega.
(* exists ([]: list cand). 
 exists ([]: list cand).
 intuition. *)
Qed.

Lemma ACT_TransferElected_SanityCheck_App : SanityCheck_TransferElected_App ACT_TransferElected.
Proof.
 unfold SanityCheck_TransferElected_App.
 intros.
 destruct H0 as [H1 [H2 [H3 H4]]].
 specialize (list_nonempty_type cand bl1 H2). intro Hyp. destruct Hyp as [head [tail Hyp1]].
 exists (state (last (p head) [], t, fun d => if (cand_eq_dec d head) then [] else (p d), (tail,bl2), e, h)).
 unfold ACT_TransferElected. exists (last (p head) []). exists t. exists p.
 exists (fun d => if (cand_eq_dec d head) then [] else (p d)).
 exists (head::tail, (bl2: list cand)). exists (tail, (bl2: list cand)). exists h. exists e. rewrite Hyp1 in H. simpl in H.
 intuition.
 exists tail. exists head. exists bl2.
 intuition.
 destruct (cand_eq_dec head head) as [i | j]. reflexivity. contradict j. auto.
 destruct (cand_eq_dec d head) as [i | j]. contradiction i. reflexivity.

exists tail. exists head. exists bl2. intuition.
destruct (cand_eq_dec head head) as [i | j]. auto. contradict j. reflexivity.
destruct (cand_eq_dec d head) as [i |j]. contradiction. auto.
Qed.

Lemma ACT_TransferElected_SanityCheck_Red : SanityCheck_TransferElected_Red ACT_TransferElected.
Proof.
 unfold SanityCheck_TransferElected_Red.
 intros.
 unfold ACT_TransferElected in H.
 destruct H as [nba [t [p [np [bl [nbl [h [e H1]]]]]]]].
 destruct H1 as [H11 [H12 [H13 H14]]].
 destruct H14 as [l [candid [bl2 H141]]].
 destruct H141 as [H1411 H1412].
 destruct H1411 as [H3 [H4 H5]].
 exists nba. exists t. exists p. exists np. exists bl. exists nbl. exists h. exists e.
 intuition.  
 rewrite H3.
 rewrite H4.
 simpl.
(* left. *)
 omega.
 assert (Leneq: forall d, In d bl2 -> length (concat (p d)) = length (concat (np d))).
 intros d Assum.
 specialize (Bl_hopeful_NoIntersect premise [] t p bl e h). 
 intuition.
 assert (Hypos: d <> candid). intro HypoAux. specialize (b candid). rewrite H3 in b. simpl in b.
 apply b. left;auto. rewrite HypoAux in Assum. auto.
 specialize (H2 d Hypos). rewrite H2. reflexivity.
 specialize (map_ext_in (fun c => length (concat (p c))) (fun c => length (concat (np c))) bl2 Leneq).
 intro H0. rewrite H3. simpl.  rewrite H4. simpl. rewrite H0. auto.
Qed.

Lemma ACT_Elect_SanityCheck_App : SanityCheck_Elect_App ACT_Elect.
Proof.
 unfold SanityCheck_Elect_App. 
 intros premise t p bl e h H X.
 unfold ACT_Elect.
 specialize (constructing_electable_first).
 intro H1.
 destruct X as [c [X1 X2]].
 assert (Hyp: length (proj1_sig e) < st).
 omega. 
 specialize (H1 e (hd nty t) h quota Hyp (proj2_sig h)).
 destruct H1 as [listElected H11].
 destruct H11 as [H111 [H112 [H113 [H114 H115]]]].
 specialize (Removel_nodup listElected (proj1_sig h) (proj2_sig h)). intro NoDupH.
 assert (Assum: length ((proj1_sig e) ++ listElected) <= st).
 rewrite app_length.
 omega.
 exists (state ([], t, fun c => update_pile_ManualACT p (hd nty t) listElected quota c, 
((fst bl) ++ listElected, snd bl), exist _ ((proj1_sig e) ++ listElected) Assum, 
                                   exist _ (Removel listElected (proj1_sig h)) NoDupH)). 
 exists ([]: list ballot).  exists t. exists p. exists (fun x => update_pile_ManualACT p (hd nty t) listElected quota x).
 exists bl. exists ((fst bl) ++ listElected, snd bl). exists (exist _ (Removel listElected (proj1_sig h)) NoDupH).
 exists h. exists e. exists (exist (fun v => length v <= st) ((proj1_sig e) ++ listElected) Assum).
 split. auto.
 exists listElected.
 intuition.
 assert (NonEmptyElected: length listElected = 0).
 rewrite H2.
 simpl. reflexivity.
 assert (VacantSeat: length (listElected) < st - (length (proj1_sig e))).
 rewrite app_length in Assum.
 rewrite NonEmptyElected in Assum.
 omega.
 specialize (H115 c).
 intuition. 
 rewrite H2 in H3.
 inversion H3. 
 simpl.
 unfold Leqe.
 apply Permutation_App.
 apply (nodup_permutation).
 intros candid HypCand. 
 specialize (H111 candid HypCand).
 intuition. 
 assumption.
 apply (proj2_sig h).
 simpl.
 unfold Leqe.
 apply Permutation_refl.
 unfold update_pile_ManualACT.
 destruct (cand_in_dec c0 listElected) as [i |j].
 trivial. 
 contradict j. assumption.
 unfold update_pile_ManualACT.
 destruct (cand_in_dec c0 listElected) as [i |j].
 contradict i.
 assumption.
 auto. 
Qed.

Lemma subList_CandAll : forall l, incl l cand_all. 
Proof.
 intro l.
 unfold incl.
 intros.
   apply (cand_finite a).
Qed. 

Hypothesis noDup_elect : forall j: Machine_States, forall ba t p bl e h, 
  j = state (ba,t,p,bl,e,h) -> NoDup (proj1_sig e).

Variable A : Type.

 Inductive Add (a:Cand) : list Cand -> list Cand -> Prop :=
    | Add_head l : Add a l (a::l)
    | Add_cons x l l' : Add a l l' -> Add a (x::l) (x::l').

Lemma Add_app a l1 l2 : Add a (l1++l2) (l1++a::l2).
  Proof.
   induction l1; simpl; now constructor.
  Qed.

 Lemma Add_inv a l : In a l -> exists l', Add a l' l.
  Proof.
   intro Ha. destruct (in_split _ _ Ha) as (l1 & l2 & ->).
   exists (l1 ++ l2). apply Add_app.
  Qed.


  Lemma Add_length a l l' : Add a l l' -> length l' = S (length l).
  Proof.
   induction 1; simpl; auto with arith.
  Qed.


  Lemma Add_in a l l' : Add a l l' ->
   forall x, In x l' <-> In x (a::l).
  Proof.
   induction 1; intros; simpl in *; rewrite ?IHAdd; tauto.
  Qed.

  Lemma incl_Add_inv a l u v :
    ~In a l -> incl (a::l) v -> Add a u v -> incl l u.
  Proof.
   intros Ha H AD y Hy.
   assert (Hy' : In y (a::u)).
   { rewrite <- (Add_in a u v AD). apply H; simpl; auto. }
   destruct Hy'; [ subst; now elim Ha | trivial ].
  Qed.

 Lemma NoDup_incl_length (l: list Cand) l' :
    NoDup l -> incl l l' -> length l <= length l'.
  Proof.
   intros N. revert l'. induction N as [|a l Hal N IH]; simpl.
   - auto with arith.
   - intros l' H.
     destruct (Add_inv a l') as (l'', AD). { apply H; simpl; auto. }
     rewrite (Add_length a l'' l' AD). apply le_n_S. apply IH.
     now apply incl_Add_inv with a l'.
  Qed.

Lemma ACT_Elect_SanityCheck_Red : SanityCheck_Elect_Red ACT_Elect.
Proof.
 unfold SanityCheck_Elect_Red.
 intros premise conclusion H.
 unfold ACT_Elect in H.
 destruct H as [nba [t [p [np [bl [nbl [nh [h [e [ne H1]]]]]]]]]].
 exists nba. exists t. exists p; exists np. exists bl. exists nbl. exists e. exists ne. exists nh. exists h. 
 destruct H1 as [H11 H12].
 destruct H12 as [l H121].
 intuition.
 unfold Leqe in H6.
 specialize (Permutation_length H6). intro Permut_length.
 assert (lem: forall n m k, k <= n -> m <= n -> m < k -> (n - k < n - m)).
  intros. omega.
 apply lem.
 specialize (noDup_elect (state([],t,np,nbl,ne,nh)) [] t np nbl ne nh eq_refl). 
 apply (NoDup_incl_length (` ne) cand_all).
 auto.
 apply subList_CandAll.
 specialize (noDup_elect (state([],t,p,bl,e,h)) [] t p bl e h eq_refl).
 apply (NoDup_incl_length (` e) cand_all). 
 auto.
 apply subList_CandAll.

 rewrite Permut_length.
 rewrite  app_length.
 specialize (list_nonempty_type cand l H1). intro X.
 destruct X as [c [l' HX]].
 rewrite HX. (*Search (_ - _  < _).
 Require Import Psatz. Require Import Coq.omega.PreOmega. zify.*)
 simpl.  
 omega.  
 rewrite H.
 assumption.
(* unfold Leqe in H5.
 specialize (Permutation_length H5). intro H8.
 rewrite H8.
 rewrite app_length.
 specialize (list_nonempty_type cand l H1). intro X.
 destruct X as [c [l' HX]]. 
 rewrite HX.
 simpl.
 omega.*)
Qed.

(*
Lemma ACTTran2_SanityCheck_App : SanityCheck_Transfer2_App ACT_TransferElected2. 
Proof.
 unfold SanityCheck_Transfer2_App.
 intros. 
 unfold ACT_TransferElected2.
 destruct H0 as [H1 [H2 [H3 H4]]].
 specialize (list_nonempty_type cand bl1 H2). intro Nonempty_bl.
 destruct Nonempty_bl as [Headbl1 [Tailbl1 bl1None]].
 
 exists (state (concat (p Headbl1), t, fun x => if (cand_eq_dec x Headbl1) then [] else p x, 
                (Tailbl1, bl2), e, h)).  
 exists (concat (p Headbl1)).
 exists t. exists p. exists (fun x => if (cand_eq_dec x Headbl1) then [] else (p x)).
 exists (Headbl1:: Tailbl1, c:: bl2). exists (Tailbl1,bl2). exists h. exists e.
 rewrite bl1None in H.
 intuition.
 exists Tailbl1. exists Headbl1. exists c. exists bl2.
 intuition.
 destruct (cand_eq_dec Headbl1 Headbl1) as [i | j].
 reflexivity.
 contradict j.  auto.
 destruct (cand_eq_dec d Headbl1) as [i | j].
 contradict i.
 auto.
 reflexivity.
Qed.

Lemma ACTTran2_SanityCheck_Red : SanityCheck_Transfer_Red ACT_TransferElected2.
Proof.
 unfold SanityCheck_Transfer_Red.
 intros.
 unfold ACT_TransferElected2 in H.
 destruct H as [nba [t [p [np [bl [nbl [h [e H1]]]]]]]].
 destruct H1 as [H11 [H12 [H13 H14]]].
 destruct H14 as [Tbl1 [Hbl1 [Hbl2 [Tbl2 H15]]]].
 exists nba.
 exists t. exists p. exists np. exists bl. exists nbl. exists h. exists e.
 destruct H15 as [H15 H152].
 destruct H15 as [HH1 HH2].
 destruct HH2 as [HH21 [HH22 [HH23 [HH24 HH25]]]].
 assert (Hypo: forall d, In d Tbl2 -> p (d) = np (d)).
 intros d Hy.
 assert (hypos: d <> Hbl1). intro contHypos. rewrite contHypos in Hy.
 specialize (Bl_hopeful_NoIntersect (state ([],t,p,bl, e,h)) [] t p bl e h (eq_refl)).  
 destruct Bl_hopeful_NoIntersect as [i j]. 
 specialize (j Hbl1).
 rewrite HH1 in j.
 assert (hyu: In Hbl1 (fst (Hbl1:: Tbl1, Hbl2:: Tbl2))).
 simpl. left;auto.
 specialize (j hyu).
 apply j.
 simpl.
 right;assumption.
 specialize (HH25 d hypos).
 auto.
 split.  auto.
 split. left. rewrite HH1. rewrite HH21. 
 simpl. rewrite HH23.
 assert (Leneq: forall d, In d Tbl2 -> length (concat (p d)) = length (concat (np d))).
 intros d he.
 specialize (Hypo d he). rewrite Hypo. auto.
 specialize (map_ext_in (fun c => length (concat (p c))) (fun d => length (concat (np d))) Tbl2 Leneq). 
 intro map_equal.
 rewrite map_equal.
 simpl.
 omega.
 auto.
Qed.
*)

Hypothesis Bl_NoDup : forall j: Machine_States, forall ba t p bl e h, 
  j = state (ba,t,p,bl,e,h) -> NoDup (snd bl).


Lemma ACT_TransferRemoved_SanityCheck_App : SanityCheck_TransferRemoved_App ACT_TransferElim.
Proof.
 unfold SanityCheck_TransferRemoved_App.
 intros.
 (* destruct H0 as [H1 [H2 [H3 H4]]]. *)
destruct H0 as [H1 [H2 H3]].
 unfold ACT_TransferElim.
 exists (state (((last (groupbysimple _ (sort (concat (p c)))) []): list ballot),
 t, fun d => if (cand_eq_dec d c) then (removelast (groupbysimple _ (sort (concat (p c))))) else p d, (bl1, c::bl2), e, h)). 
 exists (last (groupbysimple _ (sort (concat (p c)))) []). 
 exists t. exists p. exists (fun d => if (cand_eq_dec d c) 
   then (removelast ((groupbysimple _ (sort (concat (p c))))))  else p d). 
 exists (bl1,c::bl2). 
 exists (bl1, c::bl2). 
exists h. exists e. intuition. 
  exists bl1. exists c. exists bl2. intuition.
(*specialize (list_nonempty_type cand bl1 H2). intro Nbl1.
 destruct Nbl1 as [Hbl1 [Tbl1 bl1N]].
 exists Tbl1. exists Hbl1. exists c. exists bl2.
 rewrite bl1N.
 intuition. *)
 destruct (cand_eq_dec c c) as [i | j]. simpl. trivial.
 contradict j. reflexivity.
 destruct (cand_eq_dec d c) as [i |j]. simpl. trivial.
 contradiction i. reflexivity.
Qed.

Lemma concat_app : forall (A:Type) (l1: list (list A)) l2, concat (l1 ++ l2) = concat l1 ++ concat l2.
Proof.
  intros.
  induction l1 as [|x l1 IH]. induction l2. simpl.
  reflexivity. simpl. auto.
  simpl. rewrite IH; apply app_assoc.
Qed.
 
Lemma ACT_TransferRemoved_SanityCheck_Red: SanityCheck_TransferRemoved_Red ACT_TransferElim.
Proof.
 unfold SanityCheck_TransferRemoved_Red. 
 intros.
 unfold ACT_TransferElim in H.
 destruct H as [nba [t [p [np [bl [nbl [h [e H1]]]]]]]].
 destruct H1 as [H11 [H12 [H13 H14]]].
 destruct H14 as [bl1 [Hbl2 [Tbl2 H15]]]. 
 (*destruct H14 as [bl1 [c' [l' H15]]].*)
 destruct H15 as [H151 H152].  
 destruct H151 as [K1 [K11 K2]].
 destruct K2 as [K21 [K22 [K23 K24]]].
 exists nba. exists t. exists p. exists np. exists bl. exists nbl. exists h. exists e.
 split. assumption.
 split. rewrite K1. rewrite K21. simpl. auto.
 rewrite K1. rewrite K21. simpl.

 assert (Tbl2_NoDup: NoDup (Hbl2 :: Tbl2)). 
 specialize (Bl_NoDup (state ([],t,p,bl,e,h)) [] t p bl e h (eq_refl)).
 rewrite K1 in Bl_NoDup.
 simpl in Bl_NoDup.
 assumption.
 assert (Hbl2_notInTail: ~ In Hbl2 Tbl2). 
 intro Cont.
 inversion Tbl2_NoDup.
 apply H1. assumption.
 assert (Piles_eq_Tbl2: forall d, In d Tbl2 -> p d = np d).
 intros d InTbl2.
 assert (not_eq_d: d <> Hbl2).
 intro cont. rewrite cont in InTbl2. apply Hbl2_notInTail. assumption.
 specialize (K24 d not_eq_d).
 auto.
 assert (Len_piles_eq: forall d, In d Tbl2 -> length (concat (p d)) = length (concat (np d))).
 intros d Hy.
 specialize (Piles_eq_Tbl2 d Hy).
 rewrite Piles_eq_Tbl2. auto.
 specialize (map_ext_in (fun c => length (concat (p c))) (fun c => length (concat (np c))) Tbl2 Len_piles_eq). 
 intro nice.
 rewrite nice.
 (* rewrite K24.*)
 rewrite K23.
 assert (Hypo: (groupbysimple _ (sort (concat (p Hbl2)))) <> []).
 apply groupbysimple_not_empty.
 apply sherin. 
 auto.  
 assert (Hypo2: groupbysimple _ (sort (concat (p Hbl2))) = 
(removelast (groupbysimple _ (sort (concat (p Hbl2))))) ++ [last (groupbysimple _ (sort (concat (p Hbl2)))) []]).
 apply app_removelast_last.
 assumption.
 assert (Hypo222: concat (groupbysimple _ (sort (concat (p Hbl2)))) =
                  concat ((removelast (groupbysimple _ (sort (concat (p Hbl2)))))
                            ++
                            [last (groupbysimple _ (sort (concat (p Hbl2)))) []])).
 apply f_equal. assumption.
 rewrite concat_app in Hypo222. 

 assert (Hypo22: length (concat (groupbysimple _ (sort (concat (p Hbl2))))) = 
 (length (concat (removelast (groupbysimple _ (sort (concat (p Hbl2)))))) + 
  length (concat [last (groupbysimple _ (sort (concat (p Hbl2)))) []]))%nat).
 rewrite <- app_length. apply f_equal. auto.
 assert (Hypolen : length
            (concat (groupbysimple {v : list cand | NoDup v /\ [] <> v} (sort (concat (p Hbl2))))) = 
                   length (concat (p Hbl2))).
 rewrite <- concat_rat. auto.
 rewrite <- Hypolen.
 rewrite  Hypo22.
 simpl.
 assert (Hlen : forall (A : Type) (l : list A),
            l <> []  -> 0 < length l).  
 intros. destruct l. contradiction H. auto. simpl. omega.
 specialize (groupby_notempty _ (sort (concat (p Hbl2)))). intros.
 pose proof (sortedList_notempty (concat (p Hbl2)) K11).
 specialize (H H0). 
 specialize (Hlen _ _ H).
 rewrite app_nil_r. split.
 apply Nat.add_lt_mono_r.
 apply NPeano.Nat.lt_add_pos_r. trivial. rewrite <- K21.
 auto.
Qed.


Variable bs: list ballot.

Definition ActSTV := (mkSTV 
    (ACT_InitStep) (ACTInitStep_SanityCheck_App) (ACTInitStep_SanityCheck_Red) 
    (ACT_count) (ACTCount_SanityCheck_App) (ACTCount_SanityCheck_Red)
    (ACT_TransferElected) (ACT_TransferElected_SanityCheck_App) (ACT_TransferElected_SanityCheck_Red)
   (* (ACT_TransferElected2) (ACTTran2_SanityCheck_App) (ACTTran2_SanityCheck_Red) *)
    (ACT_TransferElim) (ACT_TransferRemoved_SanityCheck_App) (ACT_TransferRemoved_SanityCheck_Red)
    (ACT_Elect) (ACT_Elect_SanityCheck_App) (ACT_Elect_SanityCheck_Red)
    (ACT_elim) (ACTElim_SanityCheck_App) (ACTElim_SanityCheck_Red)
    (ACT_hwin) (ACTHwin_SanityCheck_App) (ACTHwin_SanityCheck_Red)
    (ACT_ewin) (ACTEwin_SanityCheck_App) (ACTEwin_SanityCheck_Red)).

Lemma init_stages_R_initial : ~ State_final (initial (Filter bs)).
Proof.
 intro.
 unfold State_final in H.
 destruct H.
 inversion H.
Qed.
 
Definition Act_Termination := M.Termination bs (initial (Filter bs)) init_stages_R_initial ActSTV.


End ACT.

(*End Act.*)

Extraction Language Haskell.
Extraction "Act.hs" Act_Termination.

(*End Act.*)
