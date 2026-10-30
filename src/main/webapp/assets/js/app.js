/* Hostel Room Allocation System - small UI helpers (no libraries) */
(function () {
  "use strict";

  // ---- mobile sidebar ----
  document.addEventListener("click", function (e) {
    if (e.target.closest("[data-menu]")) {
      document.body.classList.toggle("nav-open");
    } else if (document.body.classList.contains("nav-open") && !e.target.closest(".sidebar")) {
      document.body.classList.remove("nav-open");
    }
  });

  // ---- dismiss flash messages ----
  document.querySelectorAll(".alert .close").forEach(function (btn) {
    btn.addEventListener("click", function () { btn.closest(".alert").remove(); });
  });
  document.querySelectorAll(".alert[data-autohide]").forEach(function (el) {
    setTimeout(function () {
      el.style.transition = "opacity .4s";
      el.style.opacity = "0";
      setTimeout(function () { el.remove(); }, 400);
    }, 6000);
  });

  // ---- confirm before destructive actions: <form data-confirm="..."> ----
  document.addEventListener("submit", function (e) {
    var form = e.target;
    var submitter = e.submitter;
    var msg = (submitter && submitter.dataset.confirm) || form.dataset.confirm;
    if (msg && !window.confirm(msg)) {
      e.preventDefault();
      return;
    }
    // prevent double submits
    if (submitter && submitter.tagName === "BUTTON") {
      setTimeout(function () { submitter.disabled = true; }, 0);
    }
  });

  // ---- modals: <button data-open="dialogId">, <button data-close> ----
  document.addEventListener("click", function (e) {
    var opener = e.target.closest("[data-open]");
    if (opener) {
      var dlg = document.getElementById(opener.dataset.open);
      if (dlg) {
        // copy data-* values into the dialog's inputs (data-fill-name="value")
        Object.keys(opener.dataset).forEach(function (k) {
          if (k.indexOf("fill") === 0) {
            var name = k.substring(4).charAt(0).toLowerCase() + k.substring(5);
            var field = dlg.querySelector("[name='" + name + "']");
            var label = dlg.querySelector("[data-label='" + name + "']");
            if (field) field.value = opener.dataset[k];
            if (label) label.textContent = opener.dataset[k];
          }
        });
        dlg.showModal();
      }
    }
    if (e.target.closest("[data-close]")) {
      var d = e.target.closest("dialog");
      if (d) d.close();
    }
  });
  document.querySelectorAll("dialog.modal").forEach(function (dlg) {
    dlg.addEventListener("click", function (e) { if (e.target === dlg) dlg.close(); });
  });

  // ---- client-side table search: <input data-filter="#tableId"> ----
  document.querySelectorAll("[data-filter]").forEach(function (input) {
    var table = document.querySelector(input.dataset.filter);
    if (!table) return;
    input.addEventListener("input", function () {
      var q = input.value.trim().toLowerCase();
      table.querySelectorAll("tbody tr").forEach(function (tr) {
        tr.style.display = tr.textContent.toLowerCase().indexOf(q) === -1 ? "none" : "";
      });
    });
  });

  // ---- show / hide fields: <select data-toggle-value="CHANGE" data-toggle-target="#id"> ----
  document.querySelectorAll("[data-toggle-target]").forEach(function (ctrl) {
    var target = document.querySelector(ctrl.dataset.toggleTarget);
    function sync() {
      var on = ctrl.value === ctrl.dataset.toggleValue;
      target.classList.toggle("hidden", !on);
      target.querySelectorAll("select, input").forEach(function (f) { f.required = on; });
    }
    ctrl.addEventListener("change", sync);
    sync();
  });

  // ---- demo login buttons ----
  document.querySelectorAll("[data-demo-email]").forEach(function (b) {
    b.addEventListener("click", function () {
      document.querySelector("input[name='email']").value = b.dataset.demoEmail;
      document.querySelector("input[name='password']").value = b.dataset.demoPass;
    });
  });

  // ---- "pay full amount" shortcut ----
  document.querySelectorAll("[data-set-amount]").forEach(function (b) {
    b.addEventListener("click", function () {
      var input = document.querySelector("input[name='amount']");
      if (input) input.value = b.dataset.setAmount;
    });
  });
})();
