#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "patchlevel.h"
#ifdef __cplusplus
}
#endif

#include "apse.h"

#if PATCHLEVEL < 5
# define PL_na na
#endif

MODULE = String::Approx		PACKAGE = String::Approx		

PROTOTYPES: DISABLE

apse_t *
new(CLASS, pattern, ...)
	char *		CLASS
	SV *		pattern
    CODE:
	apse_t *	ap;
	apse_size_t	edit_distance;
	IV pattern_size = SvCUR(pattern);
	if (items == 2)
		edit_distance = ((pattern_size-1)/10)+1;
	else if (items == 3)
		edit_distance = (apse_size_t)SvIV(ST(2));
	else {
        	warn("Usage: new(pattern[, edit_distance])\n");
        	XSRETURN_UNDEF;
	}
	ap = apse_create((unsigned char *)SvPV(pattern, PL_na),
			 pattern_size, edit_distance);
	if (ap) {
		RETVAL = ap;
	} else {
        	warn("unable to allocate");
        	XSRETURN_UNDEF;
        }
    OUTPUT:
	RETVAL

void
DESTROY(ap)
	apse_t *	ap
    CODE:
	apse_destroy(ap);

apse_bool_t
match(ap, text)
	apse_t *	ap
	SV *		text
    CODE:
	RETVAL = apse_match(ap,
			    (unsigned char *)SvPV(text, PL_na),
			    SvCUR(text));
    OUTPUT:
	RETVAL

void
slice(ap, text)
	apse_t *	ap
	SV *		text
    PREINIT:
	apse_size_t	match_begin;
	apse_size_t	match_size;
    PPCODE:
	if (apse_slice(ap,
		       (unsigned char *)SvPV(text, PL_na),
		       SvCUR(text),
		       &match_begin,
		       &match_size)) {
		EXTEND(sp, 2);
		PUSHs(sv_2mortal(newSViv(match_begin)));
		PUSHs(sv_2mortal(newSViv(match_size)));
	}

apse_bool_t
match_next(ap, text)
	apse_t *	ap
	SV *		text
    CODE:
	RETVAL = apse_match_next(ap,
				 (unsigned char *)SvPV(text, PL_na),
				 SvCUR(text));
    OUTPUT:
	RETVAL

void
slice_next(ap, text)
	apse_t *	ap
	SV *		text
    PREINIT:
	apse_size_t	match_begin;
	apse_size_t	match_size;
    PPCODE:
	if (apse_slice_next(ap,
			    (unsigned char *)SvPV(text, PL_na),
			    SvCUR(text),
			    &match_begin,
			    &match_size)) {
		EXTEND(sp, 2);
		PUSHs(sv_2mortal(newSViv(match_begin)));
		PUSHs(sv_2mortal(newSViv(match_size)));
	}

void
set_greedy(ap)
	apse_t *	ap
    CODE:
	apse_set_greedy(ap, 1);

apse_bool_t
set_caseignore_slice(ap, ...)
	apse_t *	ap
    PREINIT:
	apse_size_t	offset;
	apse_size_t	size;
	apse_bool_t	ignore;
    CODE:
	offset = items < 2 ? 0 : (apse_size_t)SvIV(ST(1));
	size   = items < 3 ? ap->pattern_size : (apse_size_t)SvIV(ST(2));
	ignore = items < 4 ? 1 : (apse_bool_t)SvIV(ST(3));
	RETVAL = apse_set_caseignore_slice(ap, offset, size, ignore);
    OUTPUT:
	RETVAL

apse_bool_t
set_insertions(ap, insertions)
	apse_t *	ap
	apse_size_t	insertions = SvUV($arg);
    CODE:
	RETVAL = apse_set_insertions(ap, insertions);
    OUTPUT:
	RETVAL

apse_bool_t
set_deletions(ap, deletions)
	apse_t *	ap
	apse_size_t	deletions = SvUV($arg);
    CODE:
	RETVAL = apse_set_deletions(ap, deletions);
    OUTPUT:
	RETVAL

apse_bool_t
set_substitutions(ap, substitutions)
	apse_t *	ap
	apse_size_t	substitutions = SvUV($arg);
    CODE:
	RETVAL = apse_set_substitutions(ap, substitutions);
    OUTPUT:
	RETVAL

apse_bool_t
set_edit_distance(ap, edit_distance)
	apse_t *	ap
	apse_size_t	edit_distance = SvUV($arg);
    CODE:
	RETVAL = apse_set_edit_distance(ap, edit_distance);
    OUTPUT:
	RETVAL

apse_size_t
get_edit_distance(ap)
	apse_t *	ap
    CODE:
	ST(0) = sv_newmortal();
	sv_setiv(ST(0), apse_get_edit_distance(ap));

