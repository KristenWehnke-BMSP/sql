SELECT
  x.`Account ID`,
  x.`VCF ID Number`,
  x.`SF Account`,

  /* ===== Aging outputs ===== */
  x.`Aging Status`,
  x.`Aging Score`,

  /* ===== WTCHP timing/efficiency outputs ===== */
  x.`Days Enroll to Cert`,
  x.`Days Cert to Submit`,
  x.`Days Kit Received to Processed`,
  x.`Days Kit Processed to Enrollment`,
  x.`Days Certification to Current Claim`,
  x.`Days Submission to Award Letter`,
  x.`WTCHP Facility Efficiency`,
  x.`Facility Ranking Score`,
  x.`County Efficiency Status`,
  x.`WTCHP Facility`,

  /* ----- Claim Strength (0–100%; higher is better) ----- */
  x.`Strength (Facility)`,
  x.`Strength (Exclude Witness Bonus)`,
  x.`Strength (Definitive POP Qualifier)`,
  x.`Strength Score`,
  x.`Strength Upgrade Trigger`,

  /* ----- Claim Complexity (0–100%; higher = more complex) ----- */
  x.`Complexity (CMS Access Pending)`,
  x.`Complexity (County Efficiency)`,
  x.`Complexity (Witness Award)`,
  x.`Complexity (Exclude WPS)`,
  x.`Complexity (Commuter Exposure)`,
  x.`Complexity (Definitive POP Qualifier)`,
  x.`Complexity Score %`,

  /* ---------- Overall Claim Assessment (weighted) ---------- */
  LEAST(
    100,
    GREATEST(
      0,
      ROUND(
            0.30 * COALESCE(x.`Value Score`,0)
          + 0.15 * COALESCE(x.`Engagement Score`,0)
          + 0.20 * COALESCE(
                CASE
                  WHEN x.`Readiness Submission Override Flag` = 1 THEN 100
                  ELSE x.`Readiness Score`
                END
            ,0)
          + 0.15 * COALESCE(x.`Strength Score`,0)
          + 0.10 * (100 - COALESCE(x.`Aging Score`,0))
          + 0.10 * (100 - COALESCE(x.`Complexity Score %`,0))
      , 2)
    )
  ) AS `Claim Assessment Score`,

  /* ---------- Value Score (clamped) + drill-down ---------- */
  x.`Value Score`,
  x.`Value Base Points`,
  x.`Value Age Adj Points`,
  x.`Value Dependents Adj Points`,
  x.`Value Raw Total (pre-clamp)`,
  x.`Value Client Segment`,
  x.`Value Claim Type`,
  x.`Value Record Type`,
  x.`Value Age Used`,
  x.`Value Dependents Count Used`,
  x.`Value Is Economic Loss`,

  /* ---------- Ops visibility: illness tier counters ---------- */
  x.`Illness T1 Count`,
  x.`Illness T2 Count`,
  x.`Illness T3 Count`,
  x.`Illness T3 Rhinosinusitis Count`,

  /* ---------- Readiness (dynamic requirements) ---------- */
  x.`Readiness Weighting`,
  x.`Readiness Submission Override Flag` AS `Readiness Submission Override`,
  x.`Presence VCF Open Count`,
  x.`Presence WTCHP Open Count`,
  x.`Presence VCF Complete Flag`,
  x.`Presence WTCHP Complete Flag`,
  x.`Exclude Witness Presence Statements`,

  x.`Readiness Presence Points`,
  x.`Readiness WTC Health Program Points`,
  x.`Readiness Medical Records Points`,
  x.`Readiness Surrogates Documentation Points`,
  x.`Readiness Surrogates Appointment Points`,
  x.`Readiness Surrogates Points`,
  x.`Readiness Economic Loss Points`,
  x.`Readiness VCF Forms Points`,
  x.`Readiness Family Assistance Points`,
  x.`Readiness Illness Certification Points`,

  x.`Readiness Required Max (Dynamic)`,

  /* NEW: document-level statuses / sources for UI */
  x.`Initial Diagnostic Pathology Report Status`,
  x.`Letters Testamentary or LoA-Testamentary Status`,
  x.`Authorization of Fiduciary Status`,
  x.`Illness Certification Source`,
  x.`Confirmed Legal Authority`,

  /* Per-dimension readiness % (forced to 100 when override is on) */
  CASE
    WHEN x.`Readiness Submission Override Flag` = 1 THEN 100
    ELSE ROUND(x.`Readiness Presence Points`              / NULLIF(x.`Readiness Required Max (Dynamic)`,0) * 100.0, 2)
  END AS `Readiness Presence %`,

  CASE
    WHEN x.`Readiness Submission Override Flag` = 1 THEN 100
    ELSE ROUND(x.`Readiness WTC Health Program Points`    / NULLIF(x.`Readiness Required Max (Dynamic)`,0) * 100.0, 2)
  END AS `Readiness WTC Health Program %`,

  CASE
    WHEN x.`Readiness Submission Override Flag` = 1 THEN 100
    ELSE ROUND(x.`Readiness Medical Records Points`       / NULLIF(x.`Readiness Required Max (Dynamic)`,0) * 100.0, 2)
  END AS `Readiness Medical Records %`,

  CASE
    WHEN x.`Readiness Submission Override Flag` = 1 THEN 100
    ELSE ROUND(x.`Readiness Surrogates Points`            / NULLIF(x.`Readiness Required Max (Dynamic)`,0) * 100.0, 2)
  END AS `Readiness Surrogates %`,

  CASE
    WHEN x.`Readiness Submission Override Flag` = 1 THEN 100
    ELSE ROUND(x.`Readiness Economic Loss Points`         / NULLIF(x.`Readiness Required Max (Dynamic)`,0) * 100.0, 2)
  END AS `Readiness Economic Loss %`,

  CASE
    WHEN x.`Readiness Submission Override Flag` = 1 THEN 100
    ELSE ROUND(x.`Readiness VCF Forms Points`             / NULLIF(x.`Readiness Required Max (Dynamic)`,0) * 100.0, 2)
  END AS `Readiness VCF Forms %`,

  CASE
    WHEN x.`Readiness Submission Override Flag` = 1 THEN 100
    ELSE ROUND(x.`Readiness Family Assistance Points`     / NULLIF(x.`Readiness Required Max (Dynamic)`,0) * 100.0, 2)
  END AS `Readiness Family Assistance %`,

  CASE
    WHEN x.`Readiness Submission Override Flag` = 1 THEN 100
    ELSE ROUND(x.`Readiness Illness Certification Points` / NULLIF(x.`Readiness Required Max (Dynamic)`,0) * 100.0, 2)
  END AS `Readiness Illness Certification %`,

  /* Raw points and score (forced full when override on) */
  CASE
    WHEN x.`Readiness Submission Override Flag` = 1 THEN x.`Readiness Required Max (Dynamic)`
    ELSE x.`Readiness Raw Points (Dynamic)`
  END AS `Readiness Raw Points (Dynamic)`,

  CASE
    WHEN x.`Readiness Submission Override Flag` = 1 THEN 100
    ELSE x.`Readiness Score`
  END AS `Readiness Score`,

  /* === micro-optimization: sum-of-parts %, with override === */
  CASE
    WHEN x.`Readiness Submission Override Flag` = 1 THEN 100
    ELSE ROUND(
      COALESCE(ROUND(x.`Readiness Presence Points`              / NULLIF(x.`Readiness Required Max (Dynamic)`,0) * 100.0, 2),0)
    + COALESCE(ROUND(x.`Readiness WTC Health Program Points`    / NULLIF(x.`Readiness Required Max (Dynamic)`,0) * 100.0, 2),0)
    + COALESCE(ROUND(x.`Readiness Medical Records Points`       / NULLIF(x.`Readiness Required Max (Dynamic)`,0) * 100.0, 2),0)
    + COALESCE(ROUND(x.`Readiness Surrogates Points`            / NULLIF(x.`Readiness Required Max (Dynamic)`,0) * 100.0, 2),0)
    + COALESCE(ROUND(x.`Readiness Economic Loss Points`         / NULLIF(x.`Readiness Required Max (Dynamic)`,0) * 100.0, 2),0)
    + COALESCE(ROUND(x.`Readiness VCF Forms Points`             / NULLIF(x.`Readiness Required Max (Dynamic)`,0) * 100.0, 2),0)
    + COALESCE(ROUND(x.`Readiness Family Assistance Points`     / NULLIF(x.`Readiness Required Max (Dynamic)`,0) * 100.0, 2),0)
    + COALESCE(ROUND(x.`Readiness Illness Certification Points` / NULLIF(x.`Readiness Required Max (Dynamic)`,0) * 100.0, 2),0)
    , 2)
  END AS `Readiness % (Sum of Parts)`,

  /* ---------- Engagement ---------- */
  x.`Engagement Score`,
  ROUND(COALESCE(x.`Kit Return Points`,0) / 50.0 * 100.0, 2) AS `Kit %`,
  x.`Kit Return Points`,
  x.`BnF Interaction Boost`,

  /* ---------- Telephony detail ---------- */
  x.`Total SMS Count`,
  x.`OB SMS Sent`,
  x.`IB SMS Received`,
  x.`Total Call Count`,
  x.`OB Calls Made`,
  x.`IB Calls Received`,
  x.`Calls Over 2.5 Min`,
  x.`Calls Over 5 Min`,
  x.`Successful Call %`,
  x.`Successful SMS %`,
  x.`Telephony Engagement %`,
  x.`Modified Telephony Engagement %`

FROM (
  SELECT
    a.`Account ID`,
    a.`Account Name`,

    /* === Stable VCF pre-normalized in anchor === */
    a.`VCF ID Number`,

    CONCAT('<a href="https://bmsp.lightning.force.com/', a.`Account ID`, '" target="_blank">', a.`Account Name`, '</a>') AS `SF Account`,

    /* ===== Aging (optimized) ===== */
    ag.`Aging Status`,
    ag.`Aging Score`,

    /* ===== Timing (cert + CMS + account kit dates) ===== */
    DATEDIFF(cert.`cert_date`, enr.`Enrollment Date`)                           AS `Days Enroll to Cert`,
    DATEDIFF(csub.`initial_claim_submission_date`, cert.`cert_date`)           AS `Days Cert to Submit`,
    DATEDIFF(a.`Kit Processed Date`, a.`Kit Received Date`)                    AS `Days Kit Received to Processed`,
    DATEDIFF(enr.`Enrollment Date`, a.`Kit Processed Date`)                    AS `Days Kit Processed to Enrollment`,
    DATEDIFF(a.`Current/Most Recent Claim`, cert.`cert_date`)                  AS `Days Certification to Current Claim`,
    DATEDIFF(csub.`initial_award_letter_date`, csub.`initial_claim_submission_date`) AS `Days Submission to Award Letter`,

    CASE
      WHEN fac.`avg_days_enroll_to_cert` IS NULL THEN 'Unknown'
      WHEN fac.`avg_days_enroll_to_cert` < 300 THEN 'High'
      WHEN fac.`avg_days_enroll_to_cert` < 400 THEN 'Normal'
      ELSE 'Low'
    END AS `WTCHP Facility Efficiency`,
    CASE
      WHEN fac.`avg_days_enroll_to_cert` IS NULL THEN NULL
      WHEN fac.`avg_days_enroll_to_cert` < 300 THEN 25
      WHEN fac.`avg_days_enroll_to_cert` < 400 THEN 50
      ELSE 100
    END AS `Facility Ranking Score`,

    /* ===== County efficiency (count-aware; conservative) ===== */
    CASE
      WHEN csp.county_key IS NULL THEN 'Unknown'
      WHEN csp.county_sample_n < 10 THEN 'Low Sample'
      WHEN csp.conservative_days < 100 THEN 'High'
      WHEN csp.conservative_days < 200 THEN 'Normal'
      ELSE 'Low'
    END AS `County Efficiency Status`,

    /* Facility from accounts (based on earliest WTCHP Application Sent Date) */
    enr.`WTCHP Facility` AS `WTCHP Facility`,

    /* ===== Value ===== */
    LEAST(
      100,
      COALESCE(v.`Value Raw Total (pre-clamp)`,0)
      + CASE WHEN COALESCE(v.`Illness T1 Count`,0) >= 2 THEN 25 ELSE 0 END
    ) AS `Value Score`,
    v.`Value Base Points`,
    v.`Value Age Adj Points`,
    v.`Value Dependents Adj Points`,
    v.`Value Raw Total (pre-clamp)`,
    v.`Value Client Segment`,
    v.`Value Claim Type`,
    v.`Value Record Type`,
    v.`Value Age Used`,
    v.`Value Dependents Count Used`,
    v.`Value Is Economic Loss`,

    COALESCE(v.`Illness T1 Count`, 0)                AS `Illness T1 Count`,
    COALESCE(v.`Illness T2 Count`, 0)                AS `Illness T2 Count`,
    COALESCE(v.`Illness T3 Count`, 0)                AS `Illness T3 Count`,
    COALESCE(v.`Illness T3 Rhinosinusitis Count`, 0) AS `Illness T3 Rhinosinusitis Count`,

    /* ===== Readiness weighting & points (UPDATED) ===== */
    CASE WHEN a.is_deceased = 1 THEN 'Deceased' ELSE 'Living' END AS `Readiness Weighting`,

    /* NEW: override flag based on Status/Sub-Status, but turned off if a Future Amendment exists */
    CASE
      WHEN a.`Status` = 'Claim Submission'
       AND a.`Sub-Status` IN ('Ready to Submit','Submitted')
       AND COALESCE(csub.`future_amendment_flag`,0) = 0
      THEN 1 ELSE 0
    END AS `Readiness Submission Override Flag`,

    /* (weights exposed for debugging; not used downstream directly) */
    30 AS w_presence_vcf,          /* VCF Presence */
    10 AS w_presence_wtchp,        /* WTCHP Presence (living only) */
    CASE WHEN a.is_deceased = 1 THEN 0 ELSE 5 END AS w_wtc,  /* WTC Health Program */

    /* Medical Records weighting (PPP + WTCHP Cert + Illness Certification Status) */
    CASE
      WHEN COALESCE(im.med_not_needed_flag,0) = 1 THEN 0
      WHEN a.is_deceased = 1 THEN 20
      WHEN (
             COALESCE(cert.cert_flag,0) = 1
             OR COALESCE(ills.illness_cert_status_flag,0) = 1
             OR COALESCE(df.ppp_flag,0) = 1
           )
      THEN 5
      ELSE 20
    END AS w_medical,

    CASE WHEN a.is_deceased = 1 THEN 20 ELSE 0 END AS w_surrogates,
    CASE WHEN COALESCE(v.`Value Is Economic Loss`,0) = 1 THEN 20 ELSE 0 END AS w_econ,
    5  AS w_forms,
    CASE WHEN a.is_deceased = 1 THEN 10 ELSE 0 END AS w_family_assistance,
    CASE WHEN a.is_deceased = 1 THEN 0  ELSE 30 END AS w_cert,

    /* Dynamic required max (uses same medical-weight logic incl. PPP) */
    (
        30
      + (CASE WHEN a.is_deceased = 1 THEN 0 ELSE 10 END)
      + (CASE WHEN a.is_deceased = 1 THEN 0 ELSE 5 END)
      + (CASE
           WHEN COALESCE(im.med_not_needed_flag,0) = 1 THEN 0
           WHEN a.is_deceased = 1 THEN 20
           WHEN (
                  COALESCE(cert.cert_flag,0) = 1
                  OR COALESCE(ills.illness_cert_status_flag,0) = 1
                  OR COALESCE(df.ppp_flag,0) = 1
                )
           THEN 5
           ELSE 20
         END)
      + (CASE WHEN a.is_deceased = 1 THEN 10 ELSE 0 END)
      + (CASE WHEN a.is_deceased = 1 THEN 10 ELSE 0 END)
      + (CASE WHEN COALESCE(v.`Value Is Economic Loss`,0) = 1 THEN 20 ELSE 0 END)
      + 5
      + (CASE WHEN a.is_deceased = 1 THEN 10 ELSE 0 END)
      + (CASE WHEN a.is_deceased = 1 THEN 0  ELSE 30 END)
    ) AS `Readiness Required Max (Dynamic)`,

    df.`Presence VCF Open Count`,
    CASE WHEN a.is_deceased = 1 THEN NULL ELSE df.`Presence WTCHP Open Count` END AS `Presence WTCHP Open Count`,
    CASE WHEN COALESCE(df.`Presence VCF Open Count`,0) = 0 THEN 1 ELSE 0 END AS `Presence VCF Complete Flag`,
    CASE
      WHEN a.is_deceased = 1 THEN NULL
      ELSE CASE WHEN COALESCE(df.`Presence WTCHP Open Count`,0) = 0 THEN 1 ELSE 0 END
    END AS `Presence WTCHP Complete Flag`,

    a.`Exclude Witness Presence Statements`,

    /* Presence points */
    ((CASE WHEN COALESCE(df.`Presence VCF Open Count`,0) = 0 THEN 30 ELSE 0 END)
     + (CASE WHEN a.is_deceased = 0 AND COALESCE(df.`Presence WTCHP Open Count`,0) = 0 THEN 10 ELSE 0 END)
    ) AS `Readiness Presence Points`,

    ((CASE WHEN a.is_deceased = 1 THEN 0 ELSE 5 END) * COALESCE(df.wtc_flag,0)) AS `Readiness WTC Health Program Points`,

    (COALESCE(df.medical_flag,0) *
       (CASE
          WHEN COALESCE(im.med_not_needed_flag,0) = 1 THEN 0
          WHEN a.is_deceased = 1 THEN 20
          WHEN (
                 COALESCE(cert.cert_flag,0) = 1
                 OR COALESCE(ills.illness_cert_status_flag,0) = 1
                 OR COALESCE(df.ppp_flag,0) = 1
               )
          THEN 5
          ELSE 20
        END)
    ) AS `Readiness Medical Records Points`,

    ((CASE WHEN a.is_deceased = 1 THEN 10 ELSE 0 END) * COALESCE(df.surrogates_flag,0)) AS `Readiness Surrogates Documentation Points`,
    ((CASE WHEN a.is_deceased = 1 THEN 10 ELSE 0 END) * COALESCE(sfa.appt_flag,0))      AS `Readiness Surrogates Appointment Points`,
    ( (CASE WHEN a.is_deceased = 1 THEN 10 ELSE 0 END) * COALESCE(df.surrogates_flag,0)
      + (CASE WHEN a.is_deceased = 1 THEN 10 ELSE 0 END) * COALESCE(sfa.appt_flag,0)
    ) AS `Readiness Surrogates Points`,

    ((CASE WHEN COALESCE(v.`Value Is Economic Loss`,0) = 1 THEN 20 ELSE 0 END) * COALESCE(df.econ_flag,0)) AS `Readiness Economic Loss Points`,
    (COALESCE(df.vcf_forms_flag,0) * 5)                                                                    AS `Readiness VCF Forms Points`,
    ((CASE WHEN a.is_deceased = 1 THEN 10 ELSE 0 END) * COALESCE(df.family_assistance_flag,0)) AS `Readiness Family Assistance Points`,

    /* Illness Certification (PPP + Cert Letter + Illness Status all count) */
    ((CASE WHEN a.is_deceased = 1 THEN 0 ELSE 30 END) *
      (CASE
         WHEN (
                COALESCE(cert.cert_flag,0) = 1
                OR COALESCE(ills.illness_cert_status_flag,0) = 1
                OR COALESCE(df.ppp_flag,0) = 1
              )
         THEN 1 ELSE 0
       END)
    ) AS `Readiness Illness Certification Points`,

    /* NEW: IDPR, Testamentary & Fiduciary statuses (for UI) */
    CASE
      WHEN COALESCE(df.idpr_open_flag,0)   = 1 THEN 'Open'
      WHEN COALESCE(df.idpr_closed_flag,0) = 1 THEN 'Closed'
      ELSE NULL
    END AS `Initial Diagnostic Pathology Report Status`,

    CASE
      WHEN a.is_deceased = 0 THEN NULL
      WHEN COALESCE(df.loa_test_open_flag,0)   = 1 THEN 'Open'
      WHEN COALESCE(df.loa_test_closed_flag,0) = 1 THEN 'Closed'
      ELSE NULL
    END AS `Letters Testamentary or LoA-Testamentary Status`,

    CASE
      WHEN a.is_deceased = 0 THEN NULL
      WHEN COALESCE(df.auth_fid_open_flag,0)   = 1 THEN 'Open'
      WHEN COALESCE(df.auth_fid_closed_flag,0) = 1 THEN 'Closed'
      ELSE NULL
    END AS `Authorization of Fiduciary Status`,

    /* NEW: Illness Certification Source (for UI: PPP vs WTCHP letter vs status) */
    CASE
      WHEN COALESCE(df.ppp_flag,0) = 1 AND COALESCE(cert.cert_flag,0) = 1
        THEN 'PPP and WTCHP Certification Letter'
      WHEN COALESCE(df.ppp_flag,0) = 1
        THEN 'PPP'
      WHEN COALESCE(cert.cert_flag,0) = 1
        THEN 'WTCHP Certification Letter'
      WHEN COALESCE(ills.illness_cert_status_flag,0) = 1
        THEN 'Illness Certification Status'
      ELSE NULL
    END AS `Illness Certification Source`,

    /* NEW: Confirmed Legal Authority (backend strength input) */
    CASE
      WHEN a.is_deceased = 0 THEN 1
      WHEN a.is_deceased = 1 AND COALESCE(df.loa_test_closed_flag,0) = 1 THEN 1
      ELSE 0
    END AS `Confirmed Legal Authority`,

    /* Raw points */
    (
        ((CASE WHEN COALESCE(df.`Presence VCF Open Count`,0) = 0 THEN 30 ELSE 0 END)
         + (CASE WHEN a.is_deceased = 0 AND COALESCE(df.`Presence WTCHP Open Count`,0) = 0 THEN 10 ELSE 0 END))
      + ((CASE WHEN a.is_deceased = 1 THEN 0 ELSE 5 END) * COALESCE(df.wtc_flag,0))
      + (COALESCE(df.medical_flag,0) *
           (CASE
              WHEN COALESCE(im.med_not_needed_flag,0) = 1 THEN 0
              WHEN a.is_deceased = 1 THEN 20
              WHEN (
                     COALESCE(cert.cert_flag,0) = 1
                     OR COALESCE(ills.illness_cert_status_flag,0) = 1
                     OR COALESCE(df.ppp_flag,0) = 1
                   )
              THEN 5
              ELSE 20
            END))
      + ((CASE WHEN a.is_deceased = 1 THEN 10 ELSE 0 END) * COALESCE(df.surrogates_flag,0))
      + ((CASE WHEN a.is_deceased = 1 THEN 10 ELSE 0 END) * COALESCE(sfa.appt_flag,0))
      + ((CASE WHEN COALESCE(v.`Value Is Economic Loss`,0) = 1 THEN 20 ELSE 0 END) * COALESCE(df.econ_flag,0))
      + (COALESCE(df.vcf_forms_flag,0) * 5)
      + ((CASE WHEN a.is_deceased = 1 THEN 10 ELSE 0 END) * COALESCE(df.family_assistance_flag,0))
      + ((CASE WHEN a.is_deceased = 1 THEN 0 ELSE 30 END) *
         (CASE
            WHEN (
                   COALESCE(cert.cert_flag,0) = 1
                   OR COALESCE(ills.illness_cert_status_flag,0) = 1
                   OR COALESCE(df.ppp_flag,0) = 1
                 )
            THEN 1 ELSE 0
          END))
    ) AS `Readiness Raw Points (Dynamic)`,

    /* Score (%) base (pre-override) */
    LEAST(100, ROUND(
      (
        ((CASE WHEN COALESCE(df.`Presence VCF Open Count`,0) = 0 THEN 30 ELSE 0 END)
         + (CASE WHEN a.is_deceased = 0 AND COALESCE(df.`Presence WTCHP Open Count`,0) = 0 THEN 10 ELSE 0 END))
      + ((CASE WHEN a.is_deceased = 1 THEN 0 ELSE 5 END) * COALESCE(df.wtc_flag,0))
      + (COALESCE(df.medical_flag,0) *
           (CASE
              WHEN COALESCE(im.med_not_needed_flag,0) = 1 THEN 0
              WHEN a.is_deceased = 1 THEN 20
              WHEN (
                     COALESCE(cert.cert_flag,0) = 1
                     OR COALESCE(ills.illness_cert_status_flag,0) = 1
                     OR COALESCE(df.ppp_flag,0) = 1
                   )
              THEN 5
              ELSE 20
            END))
      + ((CASE WHEN a.is_deceased = 1 THEN 10 ELSE 0 END) * COALESCE(df.surrogates_flag,0))
      + ((CASE WHEN a.is_deceased = 1 THEN 10 ELSE 0 END) * COALESCE(sfa.appt_flag,0))
      + ((CASE WHEN COALESCE(v.`Value Is Economic Loss`,0) = 1 THEN 20 ELSE 0 END) * COALESCE(df.econ_flag,0))
      + (COALESCE(df.vcf_forms_flag,0) * 5)
      + ((CASE WHEN a.is_deceased = 1 THEN 10 ELSE 0 END) * COALESCE(df.family_assistance_flag,0))
      + ((CASE WHEN a.is_deceased = 1 THEN 0  ELSE 30 END) *
         (CASE
            WHEN (
                   COALESCE(cert.cert_flag,0) = 1
                   OR COALESCE(ills.illness_cert_status_flag,0) = 1
                   OR COALESCE(df.ppp_flag,0) = 1
                 )
            THEN 1 ELSE 0
          END))
      ) / NULLIF(
          30
        + (CASE WHEN a.is_deceased = 1 THEN 0 ELSE 10 END)
        + (CASE WHEN a.is_deceased = 1 THEN 0 ELSE 5 END)
        + (CASE
             WHEN COALESCE(im.med_not_needed_flag,0) = 1 THEN 0
             WHEN a.is_deceased = 1 THEN 20
             WHEN (
                    COALESCE(cert.cert_flag,0) = 1
                    OR COALESCE(ills.illness_cert_status_flag,0) = 1
                    OR COALESCE(df.ppp_flag,0) = 1
                  )
             THEN 5
             ELSE 20
           END)
        + (CASE WHEN a.is_deceased = 1 THEN 10 ELSE 0 END)
        + (CASE WHEN a.is_deceased = 1 THEN 10 ELSE 0 END)
        + (CASE WHEN COALESCE(v.`Value Is Economic Loss`,0) = 1 THEN 20 ELSE 0 END)
        + 5
        + (CASE WHEN a.is_deceased = 1 THEN 10 ELSE 0 END)
        + (CASE WHEN a.is_deceased = 1 THEN 0  ELSE 30 END)
      ,0) * 100.0, 2)) AS `Readiness Score`,

    /* ----- Strength ----- */
    CASE
      WHEN fac.`avg_days_enroll_to_cert` IS NULL THEN NULL
      WHEN fac.`avg_days_enroll_to_cert` < 300 THEN 80
      WHEN fac.`avg_days_enroll_to_cert` < 400 THEN 60
      ELSE 40
    END AS `Strength (Facility)`,

    CASE WHEN a.`Exclude Witness Presence Statements` IN (1,'1','TRUE','true') THEN 20 ELSE 0 END AS `Strength (Exclude Witness Bonus)`,

    /* NEW: strength boost from Employer Scrub definitive_pop_qualifier */
    CASE
      WHEN COALESCE(es.definitive_pop_qualifier_flag,0) = 1 THEN 10
      ELSE 0
    END AS `Strength (Definitive POP Qualifier)`,

    /* Strength Upgrade Trigger */
    CASE
      WHEN a.is_deceased = 0 AND COALESCE(st.vcf_comp_and_eligible_any, 0) = 1
        THEN 'Living: Illness.VCF Compensable & VCF Eligible'
      WHEN a.is_deceased = 1 AND COALESCE(st.dc_listed_and_vcf_eligible_any, 0) = 1
        THEN 'Deceased: Listed on Death Certificate & VCF Eligible'
      ELSE NULL
    END AS `Strength Upgrade Trigger`,

    /* Strength Score with override to 100% when trigger fires
       (PPP + WTCHP Cert Letter + Illness Status avoid missing-cert penalty) */
    CASE
      WHEN a.is_deceased = 0 AND COALESCE(st.vcf_comp_and_eligible_any, 0) = 1 THEN 100
      WHEN a.is_deceased = 1 AND COALESCE(st.dc_listed_and_vcf_eligible_any, 0) = 1 THEN 100
      ELSE
        CASE
          WHEN (
            100
            /* Facility penalty */
            - CASE
                WHEN fac.`avg_days_enroll_to_cert` IS NULL THEN 0
                WHEN fac.`avg_days_enroll_to_cert` < 300 THEN 0
                WHEN fac.`avg_days_enroll_to_cert` < 400 THEN 10
                ELSE 20
              END
            /* Witness reliance penalty */
            - CASE
                WHEN a.`Exclude Witness Presence Statements` IN (1,'1','TRUE','true') THEN 0
                ELSE 10
              END
            /* Missing illness certification penalty (PPP & cert letter count) */
            - CASE
                WHEN
                     COALESCE(ills.illness_cert_status_flag,0) = 1
                  OR COALESCE(cert.cert_flag,0) = 1
                  OR COALESCE(df.ppp_flag,0) = 1
                THEN 0
                ELSE 20
              END
            /* Timely Registration penalty */
            - CASE
                WHEN COALESCE(tr.late_registration_flag,0) = 1 THEN 10
                ELSE 0
              END
            /* VCF1 Lawsuit penalty */
            - CASE
                WHEN a.`Legal Involvement` = 'VCF1' THEN 10
                ELSE 0
              END
            /* Baseline Witness Bonus */
            + CASE
                WHEN COALESCE(w.witness_any_vcf_count,0) >= 3 THEN 10
                ELSE 0
              END
            /* Definitive POP Qualifier bonus */
            + CASE
                WHEN COALESCE(es.definitive_pop_qualifier_flag,0) = 1 THEN 10
                ELSE 0
              END
          ) < 0 THEN 0
          WHEN (
            100
            - CASE
                WHEN fac.`avg_days_enroll_to_cert` IS NULL THEN 0
                WHEN fac.`avg_days_enroll_to_cert` < 300 THEN 0
                WHEN fac.`avg_days_enroll_to_cert` < 400 THEN 10
                ELSE 20
              END
            - CASE
                WHEN a.`Exclude Witness Presence Statements` IN (1,'1','TRUE','true') THEN 0
                ELSE 10
              END
            - CASE
                WHEN
                     COALESCE(ills.illness_cert_status_flag,0) = 1
                  OR COALESCE(cert.cert_flag,0) = 1
                  OR COALESCE(df.ppp_flag,0) = 1
                THEN 0
                ELSE 20
              END
            - CASE
                WHEN COALESCE(tr.late_registration_flag,0) = 1 THEN 10
                ELSE 0
              END
            - CASE
                WHEN a.`Legal Involvement` = 'VCF1' THEN 10
                ELSE 0
              END
            + CASE
                WHEN COALESCE(w.witness_any_vcf_count,0) >= 3 THEN 10
                ELSE 0
              END
            + CASE
                WHEN COALESCE(es.definitive_pop_qualifier_flag,0) = 1 THEN 10
                ELSE 0
              END
          ) > 100 THEN 100
          ELSE
            (
              100
              - CASE
                  WHEN fac.`avg_days_enroll_to_cert` IS NULL THEN 0
                  WHEN fac.`avg_days_enroll_to_cert` < 300 THEN 0
                  WHEN fac.`avg_days_enroll_to_cert` < 400 THEN 10
                  ELSE 20
                END
              - CASE
                  WHEN a.`Exclude Witness Presence Statements` IN (1,'1','TRUE','true') THEN 0
                  ELSE 10
                END
              - CASE
                  WHEN
                       COALESCE(ills.illness_cert_status_flag,0) = 1
                    OR COALESCE(cert.cert_flag,0) = 1
                    OR COALESCE(df.ppp_flag,0) = 1
                  THEN 0
                  ELSE 20
                END
              - CASE
                  WHEN COALESCE(tr.late_registration_flag,0) = 1 THEN 10
                  ELSE 0
                END
              - CASE
                  WHEN a.`Legal Involvement` = 'VCF1' THEN 10
                  ELSE 0
                END
              + CASE
                  WHEN COALESCE(w.witness_any_vcf_count,0) >= 3 THEN 10
                  ELSE 0
                END
              + CASE
                  WHEN COALESCE(es.definitive_pop_qualifier_flag,0) = 1 THEN 10
                  ELSE 0
                END
            )
        END
    END AS `Strength Score`,

    /* ----- Kit ----- */
    kp.`Kit Return Points`,
    kp.`Has Kit Date`,

    /* ----- Telephony (details + BnF) — FILTERED by Reported Deceased Date..Today ----- */
    CAST(COALESCE(t.`Total SMS Count`,            0) AS INTEGER) AS `Total SMS Count`,
    CAST(COALESCE(t.`OB SMS Sent`,                0) AS INTEGER) AS `OB SMS Sent`,
    CAST(COALESCE(t.`IB SMS Received`,            0) AS INTEGER) AS `IB SMS Received`,
    CAST(COALESCE(t.`Total Call Count`,           0) AS INTEGER) AS `Total Call Count`,
    CAST(COALESCE(t.`OB Calls Made`,              0) AS INTEGER) AS `OB Calls Made`,
    CAST(COALESCE(t.`IB Calls Received`,          0) AS INTEGER) AS `IB Calls Received`,
    CAST(COALESCE(t.`Calls Over 2.5 Min`,         0) AS INTEGER) AS `Calls Over 2.5 Min`,
    CAST(COALESCE(t.`Calls Over 5 Min`,           0) AS INTEGER) AS `Calls Over 5 Min`,
    COALESCE(t.`Successful Call %`,               0)              AS `Successful Call %`,
    COALESCE(t.`Successful SMS %`,                0)              AS `Successful SMS %`,
    COALESCE(t.`Telephony Engagement %`,          0)              AS `Telephony Engagement %`,
    COALESCE(t.`Modified Telephony Engagement %`, 0)              AS `Modified Telephony Engagement %`,
    COALESCE(t.`BnF Interaction Boost`,           0)              AS `BnF Interaction Boost`,

    /* ===== Complexity (restored) ===== */
    CASE
      WHEN a.`Registration Action` = 'Registered (CO)'
           AND (a.`COO- Access Granted Date` IS NULL OR a.`COO- Access Granted Date` = '') THEN 30
      ELSE NULL
    END AS `Complexity (CMS Access Pending)`,

    /* ===== UPDATED: Complexity (County Efficiency) uses conservative, count-aware metric ===== */
    CASE
      WHEN a.is_deceased = 0 THEN NULL
      ELSE
        CASE
          WHEN csp.county_key IS NULL THEN NULL
          WHEN csp.county_sample_n < 10 THEN 0
          WHEN csp.conservative_days < 100 THEN -20
          WHEN csp.conservative_days < 200 THEN 0
          ELSE 20
        END
    END AS `Complexity (County Efficiency)`,

    CASE
      WHEN COALESCE(w.witness_existing_approved_count,0) > 0
      THEN (-20 * w.witness_existing_approved_count)
      ELSE NULL
    END AS `Complexity (Witness Award)`,

    CASE WHEN a.`Exclude Witness Presence Statements` IN (1,'1','TRUE','true') THEN -15 ELSE NULL END AS `Complexity (Exclude WPS)`,

    /* NEW: Complexity (Commuter Exposure) dimension */
    CASE
      WHEN a.`Exposure Reason` = 'Commuter' THEN 50
      ELSE 0
    END AS `Complexity (Commuter Exposure)`,

    /* NEW: Complexity (Definitive POP Qualifier) dimension */
    CASE
      WHEN COALESCE(es.definitive_pop_qualifier_flag,0) = 1 THEN -30
      ELSE 0
    END AS `Complexity (Definitive POP Qualifier)`,

    /* Combined Complexity Score % including Commuter Exposure & definitive_pop_qualifier */
    LEAST(
      100,
      GREATEST(
        0,
          COALESCE(
            CASE
              WHEN a.`Registration Action` = 'Registered (CO)'
               AND (a.`COO- Access Granted Date` IS NULL OR a.`COO- Access Granted Date` = '') THEN 30
              ELSE 0
            END, 0)
        + COALESCE(
            CASE
              WHEN a.is_deceased = 0 THEN 0
              WHEN csp.county_key IS NULL THEN 0
              WHEN csp.county_sample_n < 10 THEN 0
              WHEN csp.conservative_days < 100 THEN -20
              WHEN csp.conservative_days < 200 THEN 0
              ELSE 20
            END, 0)
        + (-20 * COALESCE(w.witness_existing_approved_count,0))
        + COALESCE(
            CASE
              WHEN a.`Exclude Witness Presence Statements` IN (1,'1','TRUE','true') THEN -15
              ELSE 0
            END
          , 0)
        + CASE WHEN a.`Exposure Reason` = 'Commuter' THEN 50 ELSE 0 END
        + CASE
            WHEN COALESCE(es.definitive_pop_qualifier_flag,0) = 1 THEN -30
            ELSE 0
          END
      )
    ) AS `Complexity Score %`,

    /* ----- Engagement (stage-weighted, keep BnF at +30) ----- */
    CASE
      WHEN COALESCE(kp.`Has Kit Date`,0) = 0 THEN
        LEAST(100, ROUND(
            COALESCE(t.`Telephony Engagement %`, 0)
          + COALESCE(t.`BnF Interaction Boost`, 0)
        , 2))
      ELSE
        LEAST(
          100,
          ROUND(
              (0.60 * COALESCE(t.`Telephony Engagement %`, 0))
            + (0.40 * (COALESCE(kp.`Kit Return Points`,0) / 50.0 * 100.0))
            + COALESCE(t.`BnF Interaction Boost`, 0)
          , 2)
        )
    END AS `Engagement Score`

  FROM
  /* ********** ONE-ROW-PER-ACCOUNT ANCHOR (with normalized VCF + flags) ********** */
  (
    SELECT
      `Account ID`,
      MAX(`Account Name`) AS `Account Name`,

      /* Pre-normalize VCF once (no REGEXP) */
      MAX(
        CASE
          WHEN COALESCE(
                 NULLIF(TRIM(`VCF ID Number - WD`),''),
                 NULLIF(TRIM(`VCF ID Number`),'')
               ) IS NULL
            THEN NULL
          WHEN REPLACE(
                 REPLACE(
                 REPLACE(
                 REPLACE(
                 REPLACE(
                 REPLACE(
                 REPLACE(
                 REPLACE(
                 REPLACE(
                 REPLACE(
                   COALESCE(
                     NULLIF(TRIM(`VCF ID Number - WD`),''),
                     NULLIF(TRIM(`VCF ID Number`),'')
                   ),
                 '0',''),'1',''),'2',''),'3',''),'4',''),
                 '5',''),'6',''),'7',''),'8',''),'9','') = ''
            THEN CONCAT(
                   'VCF',
                   COALESCE(
                     NULLIF(TRIM(`VCF ID Number - WD`),''),
                     NULLIF(TRIM(`VCF ID Number`),'')
                   )
                 )
          ELSE UPPER(
                 COALESCE(
                   NULLIF(TRIM(`VCF ID Number - WD`),''),
                   NULLIF(TRIM(`VCF ID Number`),'')
                 )
               )
        END
      ) AS `VCF ID Number`,

      MAX(`Record Type ID.Record Type Name`)       AS `Record Type ID.Record Type Name`,
      CASE
        WHEN MAX(`Record Type ID.Record Type Name`) = 'VCF_Deceased' THEN 1
        ELSE 0
      END AS is_deceased,

      MAX(`Status`)                                AS `Status`,
      MAX(`Sub-Status`)                            AS `Sub-Status`,
      MAX(`Sub-Status Start Date`)                 AS `Sub-Status Start Date`,
      MAX(`Exclude Witness Presence Statements`)   AS `Exclude Witness Presence Statements`,
      MAX(`WTCHP Facility`)                        AS `WTCHP Facility`,
      MAX(`Registration Action`)                   AS `Registration Action`,
      MAX(`COO- Access Granted Date`)              AS `COO- Access Granted Date`,
      MAX(`Economic Claim Evaluation`)             AS `Economic Claim Evaluation`,
      MAX(`Age Today`)                             AS `Age Today`,
      MAX(`Age at Death`)                          AS `Age at Death`,
      MAX(`Spouse/Dependent Count`)                AS `Spouse/Dependent Count`,
      MAX(`Client Segment`)                        AS `Client Segment`,
      MAX(`Kit Received Date`)                     AS `Kit Received Date`,
      MAX(`Kit Processed Date`)                    AS `Kit Processed Date`,
      MAX(`Current/Most Recent Claim`)             AS `Current/Most Recent Claim`,
      MAX(`Reported Deceased Date`)                AS `Reported Deceased Date`,
      MAX(`Signed Date`)                           AS `Signed Date`,
      MAX(`Registration Date`)                     AS `Registration Date`,
      MAX(`Legal Involvement`)                     AS `Legal Involvement`,
      MAX(`Exposure Reason`)                       AS `Exposure Reason`
    FROM `accounts`
    GROUP BY `Account ID`
  ) a

  /* ===== Aging ===== */
  LEFT JOIN (
    SELECT
      a0.`Account ID`,
      CASE
        WHEN MIN(CAST(NULLIF(NULLIF(TRIM(t.`Off-Track Trigger`),'X'), '') AS INTEGER)) IS NOT NULL
         AND DATEDIFF(CURDATE(), DATE(a0.`Sub-Status Start Date`)) >
             MIN(CAST(NULLIF(NULLIF(TRIM(t.`Off-Track Trigger`),'X'), '') AS INTEGER))
          THEN 'Off-Track'
        WHEN MIN(CAST(NULLIF(NULLIF(TRIM(t.`At Risk Trigger`),'X'), '') AS INTEGER)) IS NOT NULL
         AND DATEDIFF(CURDATE(), DATE(a0.`Sub-Status Start Date`)) >
             MIN(CAST(NULLIF(NULLIF(TRIM(t.`At Risk Trigger`),'X'), '') AS INTEGER))
          THEN 'At-Risk'
        ELSE 'On-Track'
      END AS `Aging Status`,
      CASE
        WHEN MIN(CAST(NULLIF(NULLIF(TRIM(t.`Off-Track Trigger`),'X'), '') AS INTEGER)) IS NOT NULL
         AND DATEDIFF(CURDATE(), DATE(a0.`Sub-Status Start Date`)) >
             MIN(CAST(NULLIF(NULLIF(TRIM(t.`Off-Track Trigger`),'X'), '') AS INTEGER))
          THEN 100
        WHEN MIN(CAST(NULLIF(NULLIF(TRIM(t.`At Risk Trigger`),'X'), '') AS INTEGER)) IS NOT NULL
         AND DATEDIFF(CURDATE(), DATE(a0.`Sub-Status Start Date`)) >
             MIN(CAST(NULLIF(NULLIF(TRIM(t.`At Risk Trigger`),'X'), '') AS INTEGER))
          THEN 50
        ELSE 0
      END AS `Aging Score`
    FROM (
      SELECT
        `Account ID`,
        MAX(`Record Type ID.Record Type Name`) AS `Record Type ID.Record Type Name`,
        MAX(`Status`)                          AS `Status`,
        MAX(`Sub-Status`)                      AS `Sub-Status`,
        MAX(`Sub-Status Start Date`)           AS `Sub-Status Start Date`
      FROM `accounts`
      GROUP BY `Account ID`
    ) a0
    LEFT JOIN `account_aging_config` t
      ON a0.`Record Type ID.Record Type Name` = t.`Account Record Type`
     AND a0.`Status`                          = t.`Status`
     AND a0.`Sub-Status`                      = t.`Sub-Status`
    GROUP BY a0.`Account ID`, a0.`Sub-Status Start Date`
  ) ag ON ag.`Account ID` = a.`Account ID`

  /* ===== Enrollment (earliest) + WTCHP Facility (FROM ACCOUNTS) ===== */
  LEFT JOIN (
    SELECT
      `Account ID`                       AS `Account ID`,
      MIN(`WTCHP Application Sent Date`) AS `Enrollment Date`,
      MAX(`WTCHP Facility`)              AS `WTCHP Facility`
    FROM `accounts`
    WHERE `WTCHP Application Sent Date` IS NOT NULL
    GROUP BY `Account ID`
  ) enr
    ON enr.`Account ID` = a.`Account ID`

  /* ===== Certification presence (case history OR WTCHP Certification Letter) ===== */
  LEFT JOIN (
    SELECT
      src.account_id AS `Account ID`,
      MIN(src.cert_date) AS cert_date,
      CASE WHEN MIN(src.cert_date) IS NOT NULL THEN 1 ELSE 0 END AS cert_flag
    FROM (
      SELECT
        `Case ID.Account ID` AS account_id,
        MIN(`Created Date`)  AS cert_date
      FROM `case_history`
      WHERE `Changed Field` = 'Sub_Status__c'
        AND `New Value`     = 'Certified'
      GROUP BY `Case ID.Account ID`
      UNION ALL
      SELECT
        `Account.Account ID` AS account_id,
        MIN(`Close Date`)    AS cert_date
      FROM `supporting_documents`
      WHERE `Type` = 'WTCHP Certification Letter'
        AND (
              (`Close Date` IS NOT NULL AND `Close Date` <> '')
              OR UPPER(TRIM(COALESCE(`Status`, ''))) = 'CLOSED'
            )
        AND UPPER(TRIM(COALESCE(`Status`, ''))) NOT IN ('CANCELLED','CANCELED')
      GROUP BY `Account.Account ID`
    ) src
    GROUP BY src.account_id
  ) cert ON cert.`Account ID` = a.`Account ID`

  /* ===== First CMS submission + award letter + Future Amendment flag ===== */
  LEFT JOIN (
    SELECT
      `Account` AS `Account ID`,
      MIN(`Submitted Date`)     AS `initial_claim_submission_date`,
      MIN(`Award Letter Date`)  AS `initial_award_letter_date`,
      MAX(
        CASE
          WHEN `Claim Type` = 'Amendment'
           AND `Status`     = 'Future'
          THEN 1 ELSE 0
        END
      ) AS `future_amendment_flag`
    FROM `cms_claim_submissions`
    GROUP BY `Account`
  ) csub ON csub.`Account ID` = a.`Account ID`

  /* ===== Facility averages (FROM ACCOUNTS WTCHP APPLICATION DATE) ===== */
  LEFT JOIN (
    SELECT
      en.facility                                AS `WTCHP Facility`,
      AVG(DATEDIFF(ct.cert_date, en.enrollment_date)) AS `avg_days_enroll_to_cert`
    FROM (
      SELECT
        `Account ID`                       AS account_id,
        MIN(`WTCHP Application Sent Date`) AS enrollment_date,
        MAX(`WTCHP Facility`)              AS facility
      FROM `accounts`
      WHERE `WTCHP Application Sent Date` IS NOT NULL
      GROUP BY `Account ID`
    ) en
    JOIN (
      SELECT
        src2.account_id AS `Account ID`,
        MIN(src2.cert_date) AS cert_date
      FROM (
        SELECT
          `Case ID.Account ID` AS account_id,
          MIN(`Created Date`)  AS cert_date
        FROM `case_history`
        WHERE `Changed Field` = 'Sub_Status__c'
          AND `New Value`     = 'Certified'
        GROUP BY `Case ID.Account ID`
        UNION ALL
        SELECT
          `Account.Account ID` AS account_id,
          MIN(`Close Date`)    AS cert_date
        FROM `supporting_documents`
        WHERE `Type` = 'WTCHP Certification Letter'
          AND (
                (`Close Date` IS NOT NULL AND `Close Date` <> '')
                OR UPPER(TRIM(COALESCE(`Status`, ''))) = 'CLOSED'
              )
          AND UPPER(TRIM(COALESCE(`Status`, ''))) NOT IN ('CANCELLED','CANCELED')
        GROUP BY `Account.Account ID`
      ) src2
      GROUP BY src2.account_id
    ) ct
      ON ct.`Account ID` = en.account_id
    WHERE en.enrollment_date IS NOT NULL
      AND ct.cert_date IS NOT NULL
      AND en.facility IS NOT NULL
    GROUP BY en.facility
  ) fac
    ON fac.`WTCHP Facility` = enr.`WTCHP Facility`

  /* ===== County (normalized once) ===== */
  LEFT JOIN (
    SELECT
      sf.`Account.Account ID` AS `Account ID`,
      COALESCE(NULLIF(TRIM(sf.`County`),''),'None') AS county_key
    FROM `surrogates_filings` sf
    GROUP BY sf.`Account.Account ID`, COALESCE(NULLIF(TRIM(sf.`County`),''),'None')
  ) county_for_acct
    ON county_for_acct.`Account ID` = a.`Account ID`

  /* ===== NEW: County speed with EB shrinkage + UCB penalty (conservative) ===== */
  LEFT JOIN (
    SELECT
      c.county_key,
      c.n AS county_sample_n,
      c.avg_days,
      g.mu0,
      g.sd0,
      (c.n / (c.n + 30.0)) * c.avg_days + (30.0 / (c.n + 30.0)) * g.mu0 AS eb_days,
      c.avg_days + 1.96 * COALESCE(c.sd_days, g.sd0) / NULLIF(SQRT(c.n),0) AS ucb95_days,
      GREATEST(
        (c.n / (c.n + 30.0)) * c.avg_days + (30.0 / (c.n + 30.0)) * g.mu0,
        c.avg_days + 1.96 * COALESCE(c.sd_days, g.sd0) / NULLIF(SQRT(c.n),0)
      ) AS conservative_days
    FROM (
      SELECT
        b.county_key,
        COUNT(*) AS n,
        AVG(b.days) AS avg_days,
        STDDEV_POP(b.days) AS sd_days
      FROM (
        SELECT
          COALESCE(NULLIF(TRIM(`County`),''),'None') AS county_key,
          DATEDIFF(`CP Decree`, `Filed`) AS days
        FROM `surrogates_filings`
        WHERE `Filed` IS NOT NULL
          AND `CP Decree` IS NOT NULL
      ) b
      GROUP BY b.county_key
    ) c
    CROSS JOIN (
      SELECT
        AVG(gb.days) AS mu0,
        STDDEV_POP(gb.days) AS sd0
      FROM (
        SELECT DATEDIFF(`CP Decree`, `Filed`) AS days
        FROM `surrogates_filings`
        WHERE `Filed` IS NOT NULL
          AND `CP Decree` IS NOT NULL
      ) gb
    ) g
  ) csp
    ON csp.county_key = county_for_acct.county_key

  /* ===== Value components (illness logic) ===== */
  LEFT JOIN (
    SELECT
      a2d.`Account ID`,
      ill.ill_base AS `Value Base Points`,
      CASE
        WHEN a2d.is_el = 1
         AND (
               (a2d.`Record Type ID.Record Type Name` = 'VCF'          AND a2d.`Age Today`    < 60)
            OR (a2d.`Record Type ID.Record Type Name` = 'VCF_Deceased' AND a2d.`Age at Death` < 60)
         )
      THEN 5 ELSE 0 END AS `Value Age Adj Points`,
      CASE
        WHEN a2d.is_el = 1 AND a2d.`Record Type ID.Record Type Name` = 'VCF_Deceased'
      THEN COALESCE(a2d.`Spouse/Dependent Count`, 0) * 2 ELSE 0 END AS `Value Dependents Adj Points`,
      ( ill.ill_base
        + CASE
            WHEN a2d.is_el = 1
             AND (
                   (a2d.`Record Type ID.Record Type Name` = 'VCF'          AND a2d.`Age Today`    < 60)
                OR (a2d.`Record Type ID.Record Type Name` = 'VCF_Deceased' AND a2d.`Age at Death` < 60)
               )
          THEN 5 ELSE 0 END
        + CASE
            WHEN a2d.is_el = 1 AND a2d.`Record Type ID.Record Type Name` = 'VCF_Deceased'
          THEN COALESCE(a2d.`Spouse/Dependent Count`, 0) * 2 ELSE 0 END
      ) AS `Value Raw Total (pre-clamp)`,
      a2d.`Client Segment` AS `Value Client Segment`,
      CASE WHEN a2d.is_el = 1 THEN 'Economic Loss' ELSE 'Non-Economic Loss Only' END AS `Value Claim Type`,
      a2d.`Record Type ID.Record Type Name` AS `Value Record Type`,
      CASE
        WHEN a2d.`Record Type ID.Record Type Name` = 'VCF'          THEN a2d.`Age Today`
        WHEN a2d.`Record Type ID.Record Type Name` = 'VCF_Deceased' THEN a2d.`Age at Death`
        ELSE NULL
      END AS `Value Age Used`,
      COALESCE(a2d.`Spouse/Dependent Count`, 0) AS `Value Dependents Count Used`,
      a2d.is_el AS `Value Is Economic Loss`,
      COALESCE(ill.t1_cnt, 0)                AS `Illness T1 Count`,
      COALESCE(ill.t2_cnt, 0)                AS `Illness T2 Count`,
      COALESCE(ill.t3_cnt, 0)                AS `Illness T3 Count`,
      COALESCE(ill.t3_rhinosinusitis_cnt, 0) AS `Illness T3 Rhinosinusitis Count`
    FROM (
      SELECT
        a2.`Account ID`,
        a2.`Client Segment`,
        a2.`Record Type ID.Record Type Name`,
        a2.`Age Today`,
        a2.`Age at Death`,
        COALESCE(a2.`Spouse/Dependent Count`, 0) AS `Spouse/Dependent Count`,
        /* REGEXP removed: match common EL variants explicitly */
        CASE
          WHEN LOWER(TRIM(a2.`Economic Claim Evaluation`))
               IN ('economic loss','economic_loss','economic-loss','economicloss','el','econ')
          THEN 1
          ELSE 0
        END AS is_el
      FROM (
        SELECT
          `Account ID`,
          MAX(`Client Segment`)                    AS `Client Segment`,
          MAX(`Record Type ID.Record Type Name`)   AS `Record Type ID.Record Type Name`,
          MAX(`Age Today`)                         AS `Age Today`,
          MAX(`Age at Death`)                      AS `Age at Death`,
          MAX(`Spouse/Dependent Count`)            AS `Spouse/Dependent Count`,
          MAX(`Economic Claim Evaluation`)         AS `Economic Claim Evaluation`
        FROM `accounts`
        GROUP BY `Account ID`
      ) a2
    ) a2d
    LEFT JOIN (
      SELECT
        d.`Account.Account ID` AS `Account ID`,
        SUM(CASE WHEN d.tier = 1 THEN 1 ELSE 0 END) AS t1_cnt,
        SUM(CASE WHEN d.tier = 2 THEN 1 ELSE 0 END) AS t2_cnt,
        SUM(CASE WHEN d.tier = 3 THEN 1 ELSE 0 END) AS t3_cnt,
        SUM(CASE WHEN d.tier = 3 AND d.is_rhino = 1 THEN 1 ELSE 0 END) AS t3_rhinosinusitis_cnt,
        CASE
          WHEN SUM(CASE WHEN d.tier = 1 THEN 1 ELSE 0 END) >= 2 THEN 60
          WHEN SUM(CASE WHEN d.tier = 1 THEN 1 ELSE 0 END) = 1
           AND SUM(CASE WHEN d.tier = 2 THEN 1 ELSE 0 END) >= 1 THEN 60
          WHEN SUM(CASE WHEN d.tier = 1 THEN 1 ELSE 0 END) = 1
           AND SUM(CASE WHEN d.tier = 2 THEN 1 ELSE 0 END) = 0 THEN 50
          WHEN SUM(CASE WHEN d.tier = 1 THEN 1 ELSE 0 END) = 0
           AND SUM(CASE WHEN d.tier = 2 THEN 1 ELSE 0 END) >= 1 THEN 35
          WHEN SUM(CASE WHEN d.tier = 1 THEN 1 ELSE 0 END) = 0
           AND SUM(CASE WHEN d.tier = 2 THEN 1 ELSE 0 END) = 0
           AND SUM(CASE WHEN d.tier = 3 THEN 1 ELSE 0 END) > 0
           AND SUM(CASE WHEN d.tier = 3 AND d.is_rhino = 1 THEN 1 ELSE 0 END) = SUM(CASE WHEN d.tier = 3 THEN 1 ELSE 0 END)
            THEN 10
          WHEN SUM(CASE WHEN d.tier = 1 THEN 1 ELSE 0 END) = 0
           AND SUM(CASE WHEN d.tier = 2 THEN 1 ELSE 0 END) = 0
           AND SUM(CASE WHEN d.tier = 3 THEN 1 ELSE 0 END) > 0
            THEN 20
          ELSE 0
        END AS ill_base
      FROM (
        SELECT DISTINCT
          ci.`Account.Account ID`,
          CAST(ci.`Tier` AS INTEGER) AS tier,
          CASE WHEN UPPER(TRIM(ci.`Illness Name`)) LIKE '%RHINOSINUSITIS%' THEN 1 ELSE 0 END AS is_rhino,
          UPPER(TRIM(ci.`Illness Name`)) AS norm_name
        FROM `claimed_illnesses` ci
        WHERE
          (ci.`Illness is Compensable` IN (1,'1',TRUE,'TRUE'))
          AND (ci.`Out of Latency`     IN (0,'0',FALSE,'FALSE'))
      ) d
      GROUP BY d.`Account.Account ID`
    ) ill ON ill.`Account ID` = a2d.`Account ID`
  ) v ON v.`Account ID` = a.`Account ID`


  /* ===== Illness Certification Status (any illness) ===== */
  LEFT JOIN (
    SELECT
      ci.`Account.Account ID` AS `Account ID`,
      MAX(
        CASE
          WHEN UPPER(TRIM(ci.`Illness Certification Status`)) IN ('REPORTED CERTIFIED','CONFIRMED CERTIFIED')
          THEN 1 ELSE 0
        END
      ) AS illness_cert_status_flag
    FROM `claimed_illnesses` ci
    GROUP BY `Account.Account ID`
  ) ills ON ills.`Account ID` = a.`Account ID`

  /* ===== Strength upgrade flags ===== */
  LEFT JOIN (
    SELECT
      ci.`Account.Account ID` AS `Account ID`,
      MAX(
        CASE
          WHEN ci.`Illness.VCF Compensable` IN (1,'1',TRUE,'TRUE')
           AND ci.`VCF Eligible`            IN (1,'1',TRUE,'TRUE')
          THEN 1 ELSE 0
        END
      ) AS vcf_comp_and_eligible_any,
      MAX(
        CASE
          WHEN ci.`Listed on Death Certificate` IN (1,'1',TRUE,'TRUE')
           AND ci.`VCF Eligible`                IN (1,'1',TRUE,'TRUE')
          THEN 1 ELSE 0
        END
      ) AS dc_listed_and_vcf_eligible_any
    FROM `claimed_illnesses` ci
    GROUP BY `Account.Account ID`
  ) st ON st.`Account ID` = a.`Account ID`

  /* ===== Timely Registration: late_registration_flag ===== */
  LEFT JOIN (
    SELECT
      ci.`Account.Account ID` AS `Account ID`,

      MAX(
        CASE
          WHEN ci.`Illness.VCF Compensable` IN (1,'1',TRUE,'TRUE')
           AND ci.`Out of Latency` NOT IN (1,'1',TRUE,'TRUE')
           AND ci.`Certification Date` IS NOT NULL
           AND acc.`Registration Date` IS NOT NULL
           AND DATEDIFF(ci.`Certification Date`, acc.`Registration Date`) >= 730
          THEN 1 ELSE 0
        END
      ) AS late_registration_flag
    FROM `claimed_illnesses` ci
    JOIN (
      SELECT
        `Account ID`,
        MAX(`Registration Date`) AS `Registration Date`
      FROM `accounts`
      GROUP BY `Account ID`
    ) acc
      ON acc.`Account ID` = ci.`Account.Account ID`
    GROUP BY ci.`Account.Account ID`
  ) tr ON tr.`Account ID` = a.`Account ID`

  /* ===== Majority-certified rule for Medical Records ===== */
  LEFT JOIN (
    SELECT
      u.account_id AS `Account ID`,
      MAX(CASE WHEN u.tier = 1 OR u.norm_name = 'EMPHYSEMA' THEN 1 ELSE 0 END) AS has_t1_or_emphysema,
      SUM(CASE WHEN u.eligible = 1 THEN 1 ELSE 0 END) AS eligible_cnt,
      SUM(CASE WHEN u.eligible = 1 AND u.is_certified = 1 THEN 1 ELSE 0 END) AS eligible_cert_cnt,
      CASE
        WHEN MAX(CASE WHEN u.tier = 1 OR u.norm_name = 'EMPHYSEMA' THEN 1 ELSE 0 END) = 1
         AND SUM(CASE WHEN u.eligible = 1 THEN 1 ELSE 0 END) > 0
         AND (2 * SUM(CASE WHEN u.eligible = 1 AND u.is_certified = 1 THEN 1 ELSE 0 END)) >= SUM(CASE WHEN u.eligible = 1 THEN 1 ELSE 0 END)
        THEN 1 ELSE 0
      END AS med_not_needed_flag
    FROM (
      SELECT DISTINCT
        ci.`Account.Account ID` AS account_id,
        CAST(ci.`Tier` AS INTEGER) AS tier,
        UPPER(TRIM(ci.`Illness Name`)) AS norm_name,
        CASE
          WHEN (ci.`Illness is Compensable` IN (1,'1',TRUE,'TRUE'))
           AND (ci.`Out of Latency` IN (0,'0',FALSE,'FALSE')) THEN 1 ELSE 0
        END AS eligible,
        CASE
          WHEN UPPER(TRIM(ci.`Illness Certification Status`)) IN ('REPORTED CERTIFIED','CONFIRMED CERTIFIED') THEN 1 ELSE 0
        END AS is_certified
      FROM `claimed_illnesses` ci
    ) u
    GROUP BY u.account_id
  ) im ON im.`Account ID` = a.`Account ID`

  /* ===== Readiness flags (supporting docs: CLOSED = CloseDate OR Status='Closed') ===== */
  LEFT JOIN (
    SELECT
      sd.`Account.Account ID` AS `Account ID`,

      /* Open presence docs: no Close Date and Status != Closed */
      SUM(
        CASE
          WHEN sd.`Document Type.Category` = 'VCF Presence'
           AND NOT (
             (sd.`Close Date` IS NOT NULL AND sd.`Close Date` <> '')
             OR UPPER(TRIM(COALESCE(sd.`Status`,''))) = 'CLOSED'
           )
          THEN 1 ELSE 0
        END
      ) AS `Presence VCF Open Count`,

      SUM(
        CASE
          WHEN sd.`Document Type.Category` = 'WTCHP Presence'
           AND NOT (
             (sd.`Close Date` IS NOT NULL AND sd.`Close Date` <> '')
             OR UPPER(TRIM(COALESCE(sd.`Status`,''))) = 'CLOSED'
           )
          THEN 1 ELSE 0
        END
      ) AS `Presence WTCHP Open Count`,

      /* Closed flags depend on Close Date OR Status='Closed' */
      MAX(
        CASE
          WHEN sd.`Document Type.Category` = 'WTC Health Program'
           AND (
                (sd.`Close Date` IS NOT NULL AND sd.`Close Date` <> '')
                OR UPPER(TRIM(COALESCE(sd.`Status`,''))) = 'CLOSED'
               )
          THEN 1 ELSE 0
        END
      ) AS wtc_flag,

      MAX(
        CASE
          WHEN sd.`Document Type.Category` = 'Medical Records'
           AND (
                (sd.`Close Date` IS NOT NULL AND sd.`Close Date` <> '')
                OR UPPER(TRIM(COALESCE(sd.`Status`,''))) = 'CLOSED'
               )
          THEN 1 ELSE 0
        END
      ) AS medical_flag,

      MAX(
        CASE
          WHEN sd.`Document Type.Category` = 'Surrogate''s'
           AND (
                (sd.`Close Date` IS NOT NULL AND sd.`Close Date` <> '')
                OR UPPER(TRIM(COALESCE(sd.`Status`,''))) = 'CLOSED'
               )
          THEN 1 ELSE 0
        END
      ) AS surrogates_flag,

      MAX(
        CASE
          WHEN sd.`Document Type.Category` = 'Economic Loss'
           AND (
                (sd.`Close Date` IS NOT NULL AND sd.`Close Date` <> '')
                OR UPPER(TRIM(COALESCE(sd.`Status`,''))) = 'CLOSED'
               )
          THEN 1 ELSE 0
        END
      ) AS econ_flag,

      MAX(
        CASE
          WHEN sd.`Document Type.Category` = 'VCF Forms'
           AND (
                (sd.`Close Date` IS NOT NULL AND sd.`Close Date` <> '')
                OR UPPER(TRIM(COALESCE(sd.`Status`,''))) = 'CLOSED'
               )
          THEN 1 ELSE 0
        END
      ) AS vcf_forms_flag,

      /* PPP present if any PPP doc (any non-cancelled status) */
      MAX(
        CASE
          WHEN UPPER(TRIM(sd.`Type`)) = 'PRIVATE PHYSICIAN PACKET (PPP)' THEN 1 ELSE 0
        END
      ) AS ppp_flag,

      /* Initial Diagnostic Pathology Report flags (Type; open vs closed) */
      MAX(
        CASE
          WHEN UPPER(TRIM(sd.`Type`)) = 'INITIAL DIAGNOSTIC PATHOLOGY REPORT'
           AND NOT (
             (sd.`Close Date` IS NOT NULL AND sd.`Close Date` <> '')
             OR UPPER(TRIM(COALESCE(sd.`Status`,''))) = 'CLOSED'
           )
          THEN 1 ELSE 0
        END
      ) AS idpr_open_flag,

      MAX(
        CASE
          WHEN UPPER(TRIM(sd.`Type`)) = 'INITIAL DIAGNOSTIC PATHOLOGY REPORT'
           AND (
                (sd.`Close Date` IS NOT NULL AND sd.`Close Date` <> '')
                OR UPPER(TRIM(COALESCE(sd.`Status`,''))) = 'CLOSED'
               )
          THEN 1 ELSE 0
        END
      ) AS idpr_closed_flag,

      /* Letters of Administration-Testamentary / Letters Testamentary flags */
      MAX(
        CASE
          WHEN UPPER(TRIM(sd.`Type`)) IN ('LETTERS OF ADMINISTRATION-TESTAMENTARY','LETTERS TESTAMENTARY')
           AND NOT (
             (sd.`Close Date` IS NOT NULL AND sd.`Close Date` <> '')
             OR UPPER(TRIM(COALESCE(sd.`Status`,''))) = 'CLOSED'
           )
          THEN 1 ELSE 0
        END
      ) AS loa_test_open_flag,

      MAX(
        CASE
          WHEN UPPER(TRIM(sd.`Type`)) IN ('LETTERS OF ADMINISTRATION-TESTAMENTARY','LETTERS TESTAMENTARY')
           AND (
                (sd.`Close Date` IS NOT NULL AND sd.`Close Date` <> '')
                OR UPPER(TRIM(COALESCE(sd.`Status`,''))) = 'CLOSED'
               )
          THEN 1 ELSE 0
        END
      ) AS loa_test_closed_flag,

      /* Authorization of Fiduciary flags */
      MAX(
        CASE
          WHEN UPPER(TRIM(sd.`Type`)) = 'AUTHORIZATION OF FIDUCIARY'
           AND NOT (
             (sd.`Close Date` IS NOT NULL AND sd.`Close Date` <> '')
             OR UPPER(TRIM(COALESCE(sd.`Status`,''))) = 'CLOSED'
           )
          THEN 1 ELSE 0
        END
      ) AS auth_fid_open_flag,

      MAX(
        CASE
          WHEN UPPER(TRIM(sd.`Type`)) = 'AUTHORIZATION OF FIDUCIARY'
           AND (
                (sd.`Close Date` IS NOT NULL AND sd.`Close Date` <> '')
                OR UPPER(TRIM(COALESCE(sd.`Status`,''))) = 'CLOSED'
               )
          THEN 1 ELSE 0
        END
      ) AS auth_fid_closed_flag,

      /* Family Assistance: closed specific titles */
      MAX(
        CASE
          WHEN (
                (sd.`Close Date` IS NOT NULL AND sd.`Close Date` <> '')
                OR UPPER(TRIM(COALESCE(sd.`Status`,''))) = 'CLOSED'
              )
           AND (
                 UPPER(TRIM(sd.`Document Type.Title`)) IN ('BURIAL EXPENSES','LIFE INSURANCE PAYOUT','LIFE INSURANCE PREMIUMS','DISABILITY RECORDS','TAX RETURNS','CAUSE-PROOF OF DEATH')
                 OR UPPER(TRIM(sd.`Document Type.Title`)) LIKE '%REPLACEMENT SERVICES%'
               )
          THEN 1 ELSE 0
        END
      ) AS family_assistance_flag

    FROM `supporting_documents` sd
    WHERE
      (
        sd.`Document Type.Category` IN ('VCF Presence','WTCHP Presence','WTC Health Program','Medical Records','Surrogate''s','Economic Loss','VCF Forms')
        OR UPPER(TRIM(sd.`Document Type.Title`)) IN ('BURIAL EXPENSES','LIFE INSURANCE PAYOUT','LIFE INSURANCE PREMIUMS','DISABILITY RECORDS','TAX RETURNS','CAUSE-PROOF OF DEATH')
        OR UPPER(TRIM(sd.`Document Type.Title`)) LIKE '%REPLACEMENT SERVICES%'
        OR UPPER(TRIM(sd.`Type`)) = 'INITIAL DIAGNOSTIC PATHOLOGY REPORT'
        OR UPPER(TRIM(sd.`Type`)) IN ('LETTERS OF ADMINISTRATION-TESTAMENTARY','LETTERS TESTAMENTARY')
        OR UPPER(TRIM(sd.`Type`)) = 'AUTHORIZATION OF FIDUCIARY'
        OR UPPER(TRIM(sd.`Type`)) = 'PRIVATE PHYSICIAN PACKET (PPP)'
      )
      AND UPPER(TRIM(COALESCE(sd.`Status`, ''))) NOT IN ('CANCELLED','CANCELED')
    GROUP BY sd.`Account.Account ID`
  ) df ON df.`Account ID` = a.`Account ID`

  /* ===== Surrogates Filings (Appointment Complete) ===== */
  LEFT JOIN (
    SELECT
      sf.`Account.Account ID` AS `Account ID`,
      MAX(
        CASE
          WHEN sf.`Record Type ID.Record Type Name` = 'Appointment'
           AND sf.`Filing Status` = 'Appointment Complete'
          THEN 1 ELSE 0
        END
      ) AS appt_flag
    FROM `surrogates_filings` sf
    GROUP BY sf.`Account.Account ID`
  ) sfa ON sfa.`Account ID` = a.`Account ID`

  /* ===== Witness relationships (deduped) ===== */
  LEFT JOIN (
    SELECT
      acr.`AccountId` AS `Account ID`,

      /* Existing logic: approved existing-client VCF witnesses */
      COUNT(
        DISTINCT CASE
          WHEN acr.`Roles` LIKE '%VCF Witness%'
           AND acr.`Existing_Client__c` IN (1,'1','TRUE','true')
           AND EXISTS (
                 SELECT 1
                 FROM `contacts` c0
                 JOIN (
                   SELECT `Account ID`, MAX(`Eligibility Status`) AS `Eligibility Status`
                   FROM `accounts`
                   GROUP BY `Account ID`
                 ) av0 ON av0.`Account ID` = c0.`Account.Id`
                 WHERE c0.`Id` = acr.`ContactId`
                   AND av0.`Eligibility Status` = 'Approved'
               )
          THEN acr.`ContactId`
        END
      ) AS witness_existing_approved_count,

      /* NEW: all VCF Witness relationships (no eligibility requirement) */
      COUNT(
        DISTINCT CASE
          WHEN acr.`Roles` LIKE '%VCF Witness%'
           AND acr.`ContactId` IS NOT NULL
           AND acr.`ContactId` <> ''
          THEN acr.`ContactId`
        END
      ) AS witness_any_vcf_count

    FROM `account_contact_relationship` acr
    GROUP BY acr.`AccountId`
  ) w ON w.`Account ID` = a.`Account ID`

  /* ===== Employer Scrub (Definitive POP Qualifier) ===== */
  LEFT JOIN (
    SELECT
      `account_id` AS `Account ID`,
      MAX(
        CASE
          WHEN `definitive_pop_qualifier` IN (1,'1','TRUE','true',TRUE)
          THEN 1 ELSE 0
        END
      ) AS definitive_pop_qualifier_flag
    FROM `employer_scrub`
    GROUP BY `account_id`
  ) es ON es.`Account ID` = a.`Account ID`

  /* ===== Kit Return Points (UPDATED: PI vs FA with decay while unreturned) ===== */
  LEFT JOIN (
    SELECT
      a2.`Account ID`,
      CASE
        WHEN a2.`Record Type ID.Record Type Name` = 'VCF_Deceased' THEN
          /* Family Assistance (FA): doubled time bands, decay if not yet returned */
          CASE
            WHEN a2.`FA Kit Sent Date` IS NULL THEN 0
            WHEN a2.`FA Kit Received Date` IS NOT NULL
                 AND a2.`FA Kit Sent Date` <= a2.`FA Kit Received Date` THEN
              CASE
                WHEN DATEDIFF(a2.`FA Kit Received Date`, a2.`FA Kit Sent Date`) < 30  THEN 50
                WHEN DATEDIFF(a2.`FA Kit Received Date`, a2.`FA Kit Sent Date`) <= 60  THEN 25
                WHEN DATEDIFF(a2.`FA Kit Received Date`, a2.`FA Kit Sent Date`) <= 120 THEN 15
                WHEN DATEDIFF(a2.`FA Kit Received Date`, a2.`FA Kit Sent Date`) <= 180 THEN 10
                ELSE 0
              END
            WHEN a2.`FA Kit Received Date` IS NULL THEN
              CASE
                WHEN DATEDIFF(CURDATE(), a2.`FA Kit Sent Date`) < 30  THEN 50
                WHEN DATEDIFF(CURDATE(), a2.`FA Kit Sent Date`) <= 60  THEN 25
                WHEN DATEDIFF(CURDATE(), a2.`FA Kit Sent Date`) <= 120 THEN 15
                WHEN DATEDIFF(CURDATE(), a2.`FA Kit Sent Date`) <= 180 THEN 10
                ELSE 0
              END
            ELSE 0
          END
        ELSE
          /* Personal Injury (PI): original bands, decay if not yet returned */
          CASE
            WHEN COALESCE(a2.`Most Recent Kit Sent Date`, a2.`Original Kit Send Date`) IS NULL THEN 0
            WHEN a2.`Kit Received Date` IS NOT NULL
                 AND COALESCE(a2.`Most Recent Kit Sent Date`, a2.`Original Kit Send Date`) <= a2.`Kit Received Date` THEN
              CASE
                WHEN DATEDIFF(a2.`Kit Received Date`, COALESCE(a2.`Most Recent Kit Sent Date`, a2.`Original Kit Send Date`)) < 15  THEN 50
                WHEN DATEDIFF(a2.`Kit Received Date`, COALESCE(a2.`Most Recent Kit Sent Date`, a2.`Original Kit Send Date`)) <= 30 THEN 25
                WHEN DATEDIFF(a2.`Kit Received Date`, COALESCE(a2.`Most Recent Kit Sent Date`, a2.`Original Kit Send Date`)) <= 60 THEN 15
                WHEN DATEDIFF(a2.`Kit Received Date`, COALESCE(a2.`Most Recent Kit Sent Date`, a2.`Original Kit Send Date`)) <= 90 THEN 10
                ELSE 0
              END
            WHEN a2.`Kit Received Date` IS NULL THEN
              CASE
                WHEN DATEDIFF(CURDATE(), COALESCE(a2.`Most Recent Kit Sent Date`, a2.`Original Kit Send Date`)) < 15  THEN 50
                WHEN DATEDIFF(CURDATE(), COALESCE(a2.`Most Recent Kit Sent Date`, a2.`Original Kit Send Date`)) <= 30 THEN 25
                WHEN DATEDIFF(CURDATE(), COALESCE(a2.`Most Recent Kit Sent Date`, a2.`Original Kit Send Date`)) <= 60 THEN 15
                WHEN DATEDIFF(CURDATE(), COALESCE(a2.`Most Recent Kit Sent Date`, a2.`Original Kit Send Date`)) <= 90 THEN 10
                ELSE 0
              END
            ELSE 0
          END
      END AS `Kit Return Points`,
      CASE
        WHEN a2.`Record Type ID.Record Type Name` = 'VCF_Deceased'
          THEN CASE WHEN a2.`FA Kit Sent Date` IS NOT NULL OR a2.`FA Kit Received Date` IS NOT NULL THEN 1 ELSE 0 END
        ELSE CASE WHEN COALESCE(a2.`Most Recent Kit Sent Date`, a2.`Original Kit Send Date`) IS NOT NULL OR a2.`Kit Received Date` IS NOT NULL THEN 1 ELSE 0 END
      END AS `Has Kit Date`
    FROM (
      SELECT
        `Account ID`,
        MAX(`Record Type ID.Record Type Name`) AS `Record Type ID.Record Type Name`,
        MAX(`FA Kit Sent Date`)                AS `FA Kit Sent Date`,
        MAX(`FA Kit Received Date`)            AS `FA Kit Received Date`,
        MAX(`Most Recent Kit Sent Date`)       AS `Most Recent Kit Sent Date`,
        MAX(`Original Kit Send Date`)          AS `Original Kit Send Date`,
        MAX(`Kit Received Date`)               AS `Kit Received Date`
      FROM `accounts`
      GROUP BY `Account ID`
    ) a2
  ) kp ON kp.`Account ID` = a.`Account ID`


  /* ===== Telephony detail + BnF (FILTERED by Reported Deceased Date..Today) ===== */
  LEFT JOIN (
    SELECT
      agg.`Account ID`,
      CAST(COALESCE(agg.total_sms,   0) AS INTEGER) AS `Total SMS Count`,
      CAST(COALESCE(agg.ob_sms,      0) AS INTEGER) AS `OB SMS Sent`,
      CAST(COALESCE(agg.ib_sms,      0) AS INTEGER) AS `IB SMS Received`,
      CAST(COALESCE(agg.total_calls, 0) AS INTEGER) AS `Total Call Count`,
      CAST(COALESCE(agg.ob_calls,    0) AS INTEGER) AS `OB Calls Made`,
      CAST(COALESCE(agg.ib_calls,    0) AS INTEGER) AS `IB Calls Received`,
      CAST(COALESCE(agg.over_2_5,    0) AS INTEGER) AS `Calls Over 2.5 Min`,
      CAST(COALESCE(agg.over_5,      0) AS INTEGER) AS `Calls Over 5 Min`,
      /* treat all completed calls equally, ignore call length thresholds */
      CASE
        WHEN COALESCE(agg.total_calls,0) = 0 THEN 0
        ELSE 100.0
      END AS `Successful Call %`,
      CASE
        WHEN COALESCE(agg.total_sms,0) = 0 THEN 0
        ELSE ROUND((COALESCE(agg.ib_sms,0) / agg.total_sms) * 100.0, 2)
      END AS `Successful SMS %`,
      CASE
        WHEN COALESCE(agg.total_calls,0)=0 AND COALESCE(agg.total_sms,0)=0 THEN 0
        ELSE LEAST(
               100.0,
               ROUND(
                 (
                   (CASE WHEN COALESCE(agg.total_calls,0)=0 THEN 0 ELSE 100.0 END) * 0.50
                   + (CASE WHEN COALESCE(agg.total_sms,0)=0  THEN 0 ELSE (COALESCE(agg.ib_sms,0) / agg.total_sms) * 100.0 END) * 0.50
                 )
                 * (CASE WHEN cfg.use_dampener = 1
                         THEN LEAST(
                                1.0,
                                SQRT(
                                  (COALESCE(agg.total_calls,0) + COALESCE(agg.total_sms,0))
                                  / cfg.min_opps
                                )
                              )
                         ELSE 1.0 END)
               , 2)
             )
      END AS `Telephony Engagement %`,
      CASE
        WHEN COALESCE(agg.total_calls,0)=0 AND COALESCE(agg.total_sms,0)=0 THEN 0
        WHEN COALESCE(agg.total_sms,0)=0 THEN 100.0
        WHEN COALESCE(agg.total_calls,0)=0 THEN ROUND((COALESCE(agg.ib_sms,0)  / agg.total_sms ) * 100.0, 2)
        ELSE ROUND((100.0 + ((COALESCE(agg.ib_sms,0) / agg.total_sms) * 100.0)) / 2.0, 2)
      END AS `Modified Telephony Engagement %`,
      CASE WHEN COALESCE(bnf.bnf_flag,0)=1 THEN cfg.bnf_bonus ELSE 0 END AS `BnF Interaction Boost`
    FROM
      (
        /* Aggregate FILTERED events */
        SELECT
          e.`Account ID`,
          SUM(CASE WHEN e.is_sms = 1  THEN 1 ELSE 0 END) AS total_sms,
          SUM(CASE WHEN e.is_sms = 1  AND e.dir='O' THEN 1 ELSE 0 END) AS ob_sms,
          SUM(CASE WHEN e.is_sms = 1  AND e.dir='I' THEN 1 ELSE 0 END) AS ib_sms,
          SUM(CASE WHEN e.is_call = 1 THEN 1 ELSE 0 END) AS total_calls,
          SUM(CASE WHEN e.is_call = 1 AND e.dir='O' THEN 1 ELSE 0 END) AS ob_calls,
          SUM(CASE WHEN e.is_call = 1 AND e.dir='I' THEN 1 ELSE 0 END) AS ib_calls,
          SUM(CASE WHEN e.is_call = 1 AND e.conn_dur >= 150 AND e.call_result NOT IN ('No Answer - Left Voicemail','No Answer - Could Not Leave Voicemail') THEN 1 ELSE 0 END) AS over_2_5,
          SUM(CASE WHEN e.is_call = 1 AND e.conn_dur >= 300 THEN 1 ELSE 0 END) AS over_5
        FROM (
          /* SMS events filtered by Reported Deceased Date..today */
          SELECT
            s.`Account` AS `Account ID`,
            COALESCE(s.`SMS Timestamp (EST)`, s.`Created Date`) AS ts,
            CASE WHEN s.`Direction`='Inbound' THEN 'I' ELSE 'O' END AS dir,
            1 AS is_sms,
            0 AS is_call,
            NULL AS conn_dur,
            NULL AS call_result
          FROM fastcall_sms_messages s
          JOIN (
            /* Engagement window: reset at Reported Deceased Date (if present), else Signed Date; end at today */
            SELECT
              `Account ID`,
              COALESCE(MAX(`Reported Deceased Date`), MAX(`Signed Date`)) AS start_date,
              CURDATE()                                                   AS end_date
            FROM accounts
            GROUP BY `Account ID`
          ) ad ON ad.`Account ID` = s.`Account`
          WHERE s.`Status` IN ('SMS Read','SMS Delivered')
            AND s.`Account` IS NOT NULL AND s.`Account` <> ''
            AND (ad.start_date IS NULL OR COALESCE(s.`SMS Timestamp (EST)`, s.`Created Date`) >= ad.start_date)
            AND COALESCE(s.`SMS Timestamp (EST)`, s.`Created Date`) <= ad.end_date

          UNION ALL

          /* Call events filtered by Reported Deceased Date..today */
          SELECT
            c.`Account.Account ID` AS `Account ID`,
            COALESCE(c.`Start Time`, c.`Created Date`) AS ts,
            CASE WHEN c.`Direction`='Inbound' THEN 'I' ELSE 'O' END AS dir,
            0 AS is_sms,
            1 AS is_call,
            c.`Connection Duration` AS conn_dur,
            c.`Call Result` AS call_result
          FROM fastcall_connections c
          JOIN (
            SELECT
              `Account ID`,
              COALESCE(MAX(`Reported Deceased Date`), MAX(`Signed Date`)) AS start_date,
              CURDATE()                                                   AS end_date
            FROM accounts
            GROUP BY `Account ID`
          ) ad ON ad.`Account ID` = c.`Account.Account ID`
          WHERE c.`Status`='Completed'
            AND c.`Account.Account ID` IS NOT NULL AND c.`Account.Account ID` <> ''
            AND (ad.start_date IS NULL OR COALESCE(c.`Start Time`, c.`Created Date`) >= ad.start_date)
            AND COALESCE(c.`Start Time`, c.`Created Date`) <= ad.end_date
        ) e
        GROUP BY e.`Account ID`
      ) agg
    CROSS JOIN (
      SELECT 1 AS use_dampener, 8.0 AS min_opps, 30.0 AS bnf_bonus
    ) cfg
    LEFT JOIN (
      /* BnF run detection on the same filtered window (Adrenaline-safe, window functions only) */
      SELECT
        qr.account_id AS `Account ID`,
        1 AS bnf_flag
      FROM (
        SELECT
          r.account_id,
          r.run_id,
          COUNT(*) AS runlen
        FROM (
          SELECT
            ev2.account_id,
            SUM(ev2.new_run) OVER (
              PARTITION BY ev2.account_id
              ORDER BY ev2.ts
              ROWS UNBOUNDED PRECEDING
            ) AS run_id
          FROM (
            SELECT
              ev.account_id,
              ev.ts,
              CASE
                WHEN LAG(ev.dir) OVER (PARTITION BY ev.account_id ORDER BY ev.ts) IS NOT NULL
                     AND LAG(ev.dir) OVER (PARTITION BY ev.account_id ORDER BY ev.ts) <> ev.dir
                     AND TIMESTAMPDIFF(
                           HOUR,
                           LAG(ev.ts) OVER (PARTITION BY ev.account_id ORDER BY ev.ts),
                           ev.ts
                         ) <= 48
                THEN 0
                ELSE 1
              END AS new_run
            FROM (
              SELECT
                s.`Account` AS account_id,
                COALESCE(s.`SMS Timestamp (EST)`, s.`Created Date`) AS ts,
                CASE WHEN s.`Direction`='Inbound' THEN 'I' ELSE 'O' END AS dir
              FROM fastcall_sms_messages s
              JOIN (
                SELECT
                  `Account ID`,
                  COALESCE(MAX(`Reported Deceased Date`), MAX(`Signed Date`)) AS start_date,
                  CURDATE()                                                   AS end_date
                FROM accounts
                GROUP BY `Account ID`
              ) ad ON ad.`Account ID` = s.`Account`
              WHERE s.`Status` IN ('SMS Read','SMS Delivered')
                AND s.`Account` IS NOT NULL AND s.`Account` <> ''
                AND (ad.start_date IS NULL OR COALESCE(s.`SMS Timestamp (EST)`, s.`Created Date`) >= ad.start_date)
                AND COALESCE(s.`SMS Timestamp (EST)`, s.`Created Date`) <= ad.end_date

              UNION ALL

              SELECT
                c.`Account.Account ID` AS account_id,
                COALESCE(c.`Start Time`, c.`Created Date`) AS ts,
                CASE WHEN c.`Direction`='Inbound' THEN 'I' ELSE 'O' END AS dir
              FROM fastcall_connections c
              JOIN (
                SELECT
                  `Account ID`,
                  COALESCE(MAX(`Reported Deceased Date`), MAX(`Signed Date`)) AS start_date,
                  CURDATE()                                                   AS end_date
                FROM accounts
                GROUP BY `Account ID`
              ) ad ON ad.`Account ID` = c.`Account.Account ID`
              WHERE c.`Status`='Completed'
                AND c.`Account.Account ID` IS NOT NULL AND c.`Account.Account ID` <> ''
                AND (ad.start_date IS NULL OR COALESCE(c.`Start Time`, c.`Created Date`) >= ad.start_date)
                AND COALESCE(c.`Start Time`, c.`Created Date`) <= ad.end_date
            ) ev
          ) ev2
        ) r
        GROUP BY r.account_id, r.run_id
        HAVING COUNT(*) >= 3
      ) qr
      GROUP BY qr.account_id
    ) bnf ON bnf.`Account ID` = agg.`Account ID`
  ) t ON t.`Account ID` = a.`Account ID`

) x;